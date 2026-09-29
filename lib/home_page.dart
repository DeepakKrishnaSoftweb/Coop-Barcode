import 'dart:convert';
import 'dart:developer';

import 'package:barcode_scanner/services/api_service.dart';
import 'package:barcode_scanner/theme/app_colors.dart';
import 'package:barcode_scanner/utils/api_path.dart';
import 'package:barcode_scanner/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'barcode_scanner_page.dart';
import 'models/product_details_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _manualController = TextEditingController();
  final List<_RecentScan> _recentScans = [];

  String scannedBarcode = '';
  bool isLoading = false;
  bool emptyData = false;
  String? errorMessage;
  List<Product> products = [];
  ScanMode _preferredMode = ScanMode.camera;

  Product? get _product => products.isEmpty ? null : products.first;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    print("Session : ${kAppStorage.getString(PrefConst.sessionId)}");
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _loadPreferences() {
    final storedMode = kAppStorage.getString(PrefConst.preferredScanMode);
    if (storedMode != null) {
      _preferredMode = ScanMode.values.firstWhere(
        (mode) => mode.name == storedMode,
        orElse: () => ScanMode.camera,
      );
    }

    final storedRecents = kAppStorage.getStringList(PrefConst.recentScans) ?? const [];
    for (final item in storedRecents) {
      try {
        final json = jsonDecode(item);
        if (json is Map<String, dynamic>) {
          _recentScans.add(_RecentScan.fromJson(json));
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Lookup'),
                  Text(
                    'COOP Discounts',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Scan product',
            onPressed: () => _openScanner(),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCurrentProduct,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _quickSearchCard(),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _mainContent(),
              ),
              if (_recentScans.isNotEmpty) ...[
                const SizedBox(height: 20),
                _recentSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickSearchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Find a product fast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Scan once — price and stock appear automatically.', style: TextStyle(color: ColorPalette.textMuted)),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: ColorPalette.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, color: ColorPalette.primaryColor, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openScanner(),
              icon: Icon(_preferredMode.icon),
              label: Text('Scan Product • ${_preferredMode.label}'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openScanner(mode: ScanMode.hardware),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scanner'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openScanner(mode: ScanMode.manual),
                    icon: const Icon(Icons.keyboard_alt_outlined),
                    label: const Text('Manual'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _manualController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              onSubmitted: fetchProduct,
              decoration: InputDecoration(
                hintText: 'Or enter barcode here',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Search barcode',
                  onPressed: () => fetchProduct(_manualController.text),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainContent() {
    if (isLoading) return _loadingCard();
    if (errorMessage != null) return _errorCard();
    if (emptyData) return _notFoundCard();
    if (_product != null) return _productCard(_product!);
    return _welcomeCard();
  }

  Widget _welcomeCard() {
    return Container(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorPalette.borderColor),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: ColorPalette.primarySoft,
            child: Icon(Icons.shopping_basket_outlined, size: 38, color: ColorPalette.primaryColor),
          ),
          SizedBox(height: 14),
          Text('Ready for the next product', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          SizedBox(height: 7),
          Text(
            'Use the camera, the supermarket barcode scanner, or manual entry. Your last scan method is remembered automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorPalette.textMuted, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Card(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Finding product…', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 4),
            Text(scannedBarcode, style: const TextStyle(color: ColorPalette.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Card(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: ColorPalette.dangerSoft,
              child: Icon(Icons.cloud_off_outlined, color: ColorPalette.dangerColor, size: 30),
            ),
            const SizedBox(height: 14),
            const Text('Unable to load product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Please check the connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorPalette.textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: scannedBarcode.isEmpty ? null : () => fetchProduct(scannedBarcode),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notFoundCard() {
    return Card(
      key: const ValueKey('notFound'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: ColorPalette.warningSoft,
              child: Icon(Icons.search_off_rounded, color: ColorPalette.warningColor, size: 34),
            ),
            const SizedBox(height: 14),
            const Text('Product not found', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'No product is linked to barcode $scannedBarcode.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorPalette.textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openScanner(),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan Another Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(Product product) {
    final price = product.ecommercePrice ?? product.listPrice ?? product.standardPrice ?? 0;
    final listPrice = product.listPrice ?? 0;
    final stock = product.qtyAvailable ?? 0;
    final hasDiscount = listPrice > 0 && listPrice > price;
    final stockColor = stock > 0 ? ColorPalette.successColor : ColorPalette.dangerColor;
    final stockSoft = stock > 0 ? ColorPalette.successSoft : ColorPalette.dangerSoft;

    return Column(
      key: ValueKey('product-${product.id}-$scannedBarcode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: ColorPalette.successSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorPalette.successColor.withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: ColorPalette.successColor, size: 20),
              SizedBox(width: 8),
              Text('Product found', style: TextStyle(color: ColorPalette.successColor, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 620;
                final image = _productImage(product);
                final details = _productDetails(product, price, listPrice, hasDiscount, stock, stockColor, stockSoft);

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 260, child: image),
                      const SizedBox(width: 22),
                      Expanded(child: details),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    image,
                    const SizedBox(height: 18),
                    details,
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _openScanner(),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan Next Product'),
        ),
        const SizedBox(height: 9),
        TextButton.icon(
          onPressed: _clearResult,
          icon: const Icon(Icons.home_outlined),
          label: const Text('Back to Product Lookup'),
        ),
      ],
    );
  }

  Widget _productImage(Product product) {
    final imagePath = product.image?.trim() ?? '';
    if (imagePath.isEmpty) return _imagePlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1.25,
        child: Image.network(
          ApiPath.imageBaseUrl(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _imagePlaceholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: const Color(0xFFF9FAFB),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 52, color: ColorPalette.textMuted),
          SizedBox(height: 8),
          Text('No product image', style: TextStyle(color: ColorPalette.textMuted)),
        ],
      ),
    );
  }

  Widget _productDetails(
    Product product,
    double price,
    double listPrice,
    bool hasDiscount,
    double stock,
    Color stockColor,
    Color stockSoft,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name?.trim().isNotEmpty == true ? product.name!.trim() : 'Unnamed Product',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'AED ${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: ColorPalette.primaryColor),
            ),
            if ((product.uomName ?? '').isNotEmpty) ...[
              const SizedBox(width: 7),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('per ${product.uomName}', style: const TextStyle(color: ColorPalette.textMuted, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 3),
          Text(
            'Regular AED ${listPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: ColorPalette.textMuted,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: stockSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(stock > 0 ? Icons.inventory_rounded : Icons.remove_shopping_cart_outlined, color: stockColor, size: 20),
              const SizedBox(width: 8),
              Text(
                stock > 0 ? '${_formatQty(stock)} in stock' : 'Out of stock',
                style: TextStyle(color: stockColor, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 480
                ? (constraints.maxWidth - 10) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _infoTile('BARCODE', scannedBarcode, Icons.qr_code_2_rounded, cardWidth),
                _infoTile('REFERENCE', product.id?.toString() ?? '-', Icons.tag_rounded, cardWidth),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _infoTile(String title, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: ColorPalette.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorPalette.primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: ColorPalette.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Recent Products', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                TextButton(onPressed: _clearRecents, child: const Text('Clear')),
              ],
            ),
            ..._recentScans.take(5).map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: ColorPalette.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history_rounded, color: ColorPalette.primaryColor),
                ),
                title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(item.barcode),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => fetchProduct(item.barcode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openScanner({ScanMode? mode}) async {
    final selectedMode = mode ?? _preferredMode;
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeScannerPage(initialMode: selectedMode),
      ),
    );

    final storedMode = kAppStorage.getString(PrefConst.preferredScanMode);
    if (storedMode != null) {
      _preferredMode = ScanMode.values.firstWhere(
        (value) => value.name == storedMode,
        orElse: () => selectedMode,
      );
      if (mounted) setState(() {});
    }

    if (result != null && result.trim().isNotEmpty) {
      log('Scanned barcode: $result');
      _manualController.text = result.trim();
      await fetchProduct(result);
    }
  }

  Future<void> fetchProduct(String barcode) async {
    debugPrint('========== FETCH PRODUCT START ==========');

    final cleanBarcode = barcode.trim();

    debugPrint('Original barcode: $barcode');
    debugPrint('Clean barcode: $cleanBarcode');

    if (cleanBarcode.isEmpty) {
      debugPrint('Barcode is empty. API will NOT be called.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter or scan a barcode first.'),
          ),
        );
      }

      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();

    if (mounted) {
      setState(() {
        scannedBarcode = cleanBarcode;
        isLoading = true;
        emptyData = false;
        errorMessage = null;
        products = [];
      });
    }

    debugPrint('Calling ApiService.getProductByBarcode...');
    debugPrint('Barcode sent to API: $cleanBarcode');

    ProductDetails? result;

    try {
      result = await ApiService.getProductByBarcode(
        cleanBarcode,
      );

      debugPrint('ApiService.getProductByBarcode completed.');
      debugPrint('Result: $result');
    } catch (e, stackTrace) {
      debugPrint('API CALL EXCEPTION: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
        'Could not connect to the product service. Please retry.';
      });

      return;
    }

    if (!mounted) return;

    // Check null BEFORE accessing result.data
    if (result == null) {
      debugPrint('API returned null.');

      setState(() {
        isLoading = false;
        errorMessage =
        'Could not connect to the product service. Please retry.';
      });

      return;
    }

    final data = result.data ?? const <Product>[];

    debugPrint('Products received: ${data.length}');
    debugPrint('Product data: $data');

    if (data.isEmpty) {
      debugPrint('API succeeded but returned no products.');

      setState(() {
        isLoading = false;
        emptyData = true;
      });

      return;
    }

    setState(() {
      products = data;
      isLoading = false;
      emptyData = false;
      errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    debugPrint('Saving recent barcode...');

    await _saveRecent(
      cleanBarcode,
      data.first,
    );

    debugPrint('========== FETCH PRODUCT END ==========');
  }

  // Future<void> fetchProduct(String barcode) async {
  //   final cleanBarcode = barcode.trim();
  //   if (cleanBarcode.isEmpty) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Enter or scan a barcode first.')),
  //       );
  //     }
  //     return;
  //   }
  //
  //   FocusScope.of(context).unfocus();
  //   HapticFeedback.selectionClick();
  //
  //   setState(() {
  //     scannedBarcode = cleanBarcode;
  //     isLoading = true;
  //     emptyData = false;
  //     errorMessage = null;
  //     products = [];
  //   });
  //
  //   final result = await ApiService.getProductByBarcode(cleanBarcode);
  //   if (!mounted) return;
  //
  //   final data = result?.data ?? const <Product>[];
  //   if (result == null) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Could not connect to the product service. Please retry.';
  //     });
  //     return;
  //   }
  //
  //   if (data.isEmpty) {
  //     setState(() {
  //       isLoading = false;
  //       emptyData = true;
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     products = data;
  //     isLoading = false;
  //     emptyData = false;
  //     errorMessage = null;
  //   });
  //
  //   HapticFeedback.mediumImpact();
  //   await _saveRecent(cleanBarcode, data.first);
  // }

  Future<void> _saveRecent(String barcode, Product product) async {
    final item = _RecentScan(
      barcode: barcode,
      name: product.name?.trim().isNotEmpty == true ? product.name!.trim() : 'Product $barcode',
    );

    _recentScans.removeWhere((value) => value.barcode == barcode);
    _recentScans.insert(0, item);
    if (_recentScans.length > 8) {
      _recentScans.removeRange(8, _recentScans.length);
    }

    await kAppStorage.setStringList(
      PrefConst.recentScans,
      _recentScans.map((value) => jsonEncode(value.toJson())).toList(),
    );

    if (mounted) setState(() {});
  }

  Future<void> _clearRecents() async {
    _recentScans.clear();
    await kAppStorage.remove(PrefConst.recentScans);
    if (mounted) setState(() {});
  }

  Future<void> _refreshCurrentProduct() async {
    if (scannedBarcode.isNotEmpty && _product != null) {
      await fetchProduct(scannedBarcode);
    }
  }

  void _clearResult() {
    setState(() {
      products = [];
      scannedBarcode = '';
      emptyData = false;
      errorMessage = null;
      isLoading = false;
      _manualController.clear();
    });
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

class _RecentScan {
  const _RecentScan({required this.barcode, required this.name});

  final String barcode;
  final String name;

  Map<String, dynamic> toJson() => {'barcode': barcode, 'name': name};

  factory _RecentScan.fromJson(Map<String, dynamic> json) {
    return _RecentScan(
      barcode: json['barcode']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
    );
  }
}
