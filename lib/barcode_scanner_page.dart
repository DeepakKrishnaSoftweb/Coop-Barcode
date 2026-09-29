import 'dart:async';

import 'package:barcode_scanner/theme/app_colors.dart';
import 'package:barcode_scanner/utils/app_constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum ScanMode { camera, hardware, manual }

extension ScanModeLabel on ScanMode {
  String get label {
    switch (this) {
      case ScanMode.camera:
        return 'Camera';
      case ScanMode.hardware:
        return 'Scanner';
      case ScanMode.manual:
        return 'Manual';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanMode.camera:
        return Icons.qr_code_scanner_rounded;
      case ScanMode.hardware:
        return Icons.document_scanner_outlined;
      case ScanMode.manual:
        return Icons.keyboard_alt_outlined;
    }
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, this.initialMode = ScanMode.camera});

  final ScanMode initialMode;

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Timer? _hidDebounce;
  late ScanMode _mode;
  bool _checkingCamera = false;
  bool _cameraSupported = true;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _prepareMode(_mode, initial: true);
  }

  @override
  void dispose() {
    _hidDebounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _prepareMode(ScanMode mode, {bool initial = false}) async {
    await kAppStorage.setString(PrefConst.preferredScanMode, mode.name);

    if (mode == ScanMode.camera) {
      if (mounted) {
        setState(() {
          _checkingCamera = true;
          _cameraSupported = true;
        });
      }

      try {
        final cameras = await availableCameras();
        _cameraSupported = cameras.isNotEmpty;
      } catch (_) {
        _cameraSupported = false;
      }

      if (mounted) {
        setState(() => _checkingCamera = false);
      }
      return;
    }

    if (!initial && mounted) {
      setState(() {
        _isScanned = false;
        _controller.clear();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _setMode(ScanMode mode) async {
    if (_mode == mode) return;
    _hidDebounce?.cancel();
    _focusNode.unfocus();
    setState(() {
      _mode = mode;
      _isScanned = false;
      _controller.clear();
    });
    await _prepareMode(mode);
  }

  Future<void> _completeScan(String value) async {
    final code = value.trim();
    if (code.isEmpty || _isScanned) return;

    _isScanned = true;
    _hidDebounce?.cancel();
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    if (_mode == ScanMode.camera) {
      try {
        await _cameraController.stop();
      } catch (_) {}
    }

    if (mounted) Navigator.pop(context, code);
  }

  void _onHardwareChanged(String value) {
    if (_isScanned) return;
    _hidDebounce?.cancel();

    // Most supermarket HID scanners send the full code in a few milliseconds.
    // Auto-submit after a short quiet period even if the scanner is not
    // configured to send ENTER/RETURN.
    if (value.trim().length >= 4) {
      _hidDebounce = Timer(const Duration(milliseconds: 180), () {
        _completeScan(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForMode()),
        actions: [
          if (_mode == ScanMode.camera && _cameraSupported && !_checkingCamera)
            IconButton(
              tooltip: 'Flash',
              onPressed: () => _cameraController.toggleTorch(),
              icon: const Icon(Icons.flashlight_on_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _modeSelector(),
            Expanded(child: _buildModeBody()),
          ],
        ),
      ),
    );
  }

  String _titleForMode() {
    switch (_mode) {
      case ScanMode.camera:
        return 'Scan Product Barcode';
      case ScanMode.hardware:
        return 'Hardware Scanner';
      case ScanMode.manual:
        return 'Enter Barcode';
    }
  }

  Widget _modeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: ScanMode.values.map((mode) {
          final selected = _mode == mode;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _setMode(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? ColorPalette.primarySoft : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? ColorPalette.primaryColor
                          : ColorPalette.borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mode.icon,
                        size: 19,
                        color: selected
                            ? ColorPalette.primaryColor
                            : ColorPalette.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          mode.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? ColorPalette.primaryColor
                                : ColorPalette.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeBody() {
    switch (_mode) {
      case ScanMode.camera:
        return _cameraView();
      case ScanMode.hardware:
        return _hardwareView();
      case ScanMode.manual:
        return _manualView();
    }
  }

  Widget _cameraView() {
    if (_checkingCamera) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_cameraSupported) {
      return _unsupportedCameraView();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: (capture) {
            if (capture.barcodes.isEmpty) return;
            final code = capture.barcodes.first.rawValue;
            if (code != null) _completeScan(code);
          },
        ),
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18)),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.78,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 14, spreadRadius: 2),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.center_focus_strong, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Place the barcode inside the frame. Detection is automatic.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _unsupportedCameraView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: ColorPalette.warningSoft,
                  child: Icon(Icons.no_photography_outlined, size: 34, color: ColorPalette.warningColor),
                ),
                const SizedBox(height: 16),
                Text('Camera is not available', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'Use the supermarket barcode scanner or enter the barcode manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorPalette.textMuted),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _setMode(ScanMode.hardware),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Use Hardware Scanner'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _setMode(ScanMode.manual),
                    icon: const Icon(Icons.keyboard_alt_outlined),
                    label: const Text('Enter Barcode'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hardwareView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: const BoxDecoration(
                    color: ColorPalette.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    size: 48,
                    color: ColorPalette.successColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Scanner Ready', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Scan any product now. No tapping is required. The product will open automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorPalette.textMuted, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  showCursor: false,
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.done,
                  onChanged: _onHardwareChanged,
                  onSubmitted: _completeScan,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.qr_code_2_rounded),
                    hintText: 'Waiting for barcode scanner…',
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, color: ColorPalette.successColor, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Auto-submit is enabled even if the scanner does not send Enter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ColorPalette.successColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _manualView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.keyboard_alt_outlined, size: 46, color: ColorPalette.primaryColor),
                  const SizedBox(height: 14),
                  Text(
                    'Enter Product Barcode',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Useful when a barcode is damaged or cannot be scanned.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColorPalette.textMuted),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _completeScan,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.qr_code_2_rounded),
                      hintText: 'Barcode number',
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        onPressed: _controller.clear,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _completeScan(_controller.text),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Find Product'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
