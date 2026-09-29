import 'package:barcode_scanner/theme/app_colors.dart';
import 'package:barcode_scanner/utils/app_spacing.dart';
import 'package:barcode_scanner/utils/build_context_extension.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool isCameraSupported = true;
  bool isLoading = true;
  bool isScanned = false;

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    checkDevice();
  }

  /// Detect camera support
  Future<void> checkDevice() async {
    try {
      final cameras = await availableCameras();
      isCameraSupported = cameras.isNotEmpty;
    } catch (e) {
      isCameraSupported = false;
    }

    setState(() {
      isLoading = false;
    });

    // If HID → focus
    if (!isCameraSupported) {
      Future.delayed(const Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(focusNode);
      });
    }
  }

  // Camera scan
  void onCameraScan(String code) {
    if (isScanned) return;
    isScanned = true;

    Navigator.pop(context, code);
  }

  // HID scan
  void onHidScan(String value) {
    if (value.isEmpty || isScanned) return;
    isScanned = true;
    SystemSound.play(SystemSoundType.click);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product Barcode")),
      body: isCameraSupported ? _cameraView() : _hidView(),
      //body: _manualBarcodeView(),
    );
  }

  // Camera UI
  Widget _cameraView() {
    return MobileScanner(
      onDetect: (barcodeCapture) {
        final String? code = barcodeCapture.barcodes.first.rawValue;
        if (code != null) {
          onCameraScan(code);
        }
      },
    );
  }

  // HID UI (POS)
  Widget _hidView() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
            },
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              showCursor: false,
              keyboardType: TextInputType.none,
              onFieldSubmitted: onHidScan,
              decoration: InputDecoration(
                hintText: "Scan barcode...",
                hintStyle: context.tt.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: ColorPalette.primaryColor,
                    width: 1.5,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ColorPalette.primaryColor,
                    width: 2,
                  ),
                ),

                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ColorPalette.primaryColor,
                    width: 1.5,
                  ),
                ),

                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: ColorPalette.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _manualBarcodeView() {
  //   return Positioned(
  //     left: 16,
  //     right: 16,
  //     bottom: 24,
  //     child: Card(
  //       elevation: 6,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             const Text(
  //               'Test barcode',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 10),
  //
  //             TextField(
  //               controller: controller,
  //               keyboardType: TextInputType.text,
  //               textInputAction: TextInputAction.done,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter barcode number',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 suffixIcon: IconButton(
  //                   icon: const Icon(Icons.clear),
  //                   onPressed: () {
  //                     controller.clear();
  //                   },
  //                 ),
  //               ),
  //               onSubmitted: (_) {
  //                 onManualBarcodeCheck();
  //               },
  //             ),
  //
  //             const SizedBox(height: 12),
  //
  //             SizedBox(
  //               height: 48,
  //               child: ElevatedButton(
  //                 onPressed: onManualBarcodeCheck,
  //                 child: const Text(
  //                   'Check Barcode',
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.blue
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // // Manual barcode check
  // void onManualBarcodeCheck() {
  //   final barcode = controller.text.trim();
  //
  //   if (barcode.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a barcode'),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   // Use the same flow as camera scanning
  //   onCameraScan(barcode);
  // }
}
