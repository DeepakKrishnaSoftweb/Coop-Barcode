import 'dart:developer';

import 'package:barcode_scanner/services/api_service.dart';
import 'package:barcode_scanner/theme/app_colors.dart';
import 'package:barcode_scanner/utils/api_path.dart';
import 'package:barcode_scanner/utils/app_spacing.dart';
import 'package:barcode_scanner/utils/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'barcode_scanner_page.dart';
import 'models/product_details_model.dart';
import 'utils/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String scannedBarcode = "";
  bool isLoading = false;
  bool emptyData = false;
  List<Product> products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(
      "Session Id : ${"session_id=${kAppStorage.getString(PrefConst.sessionId)}"}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: SizedBox(
          height: context.sh(0.1),
          child: Image.asset("assets/images/text_icon.png"),
        ),
        title: Text("Barcode Scan"),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
              );

              if (result != null) {
                log("Result : $result");
                scannedBarcode = result;
                fetchProduct(scannedBarcode);
              }
            },
            icon: Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: products.isNotEmpty
          ? orientation == Orientation.portrait
                ? portraitView()
                : landScapeView()
          : isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ColorPalette.primaryColor,
              ),
            )
          : emptyData
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No Data Found",
                    style: context.tt.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.primaryColor,
                    ),
                  ),
                  Gap(AppSpacing.lg),
                  _button(title: "Start With New Product Search"),
                ],
              ),
            )
          : _button(title: "Start With New Product Search"),
    );
  }

  Widget portraitView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  ApiPath.imageBaseUrl(products.first.image ?? ''),
                  height: context.sh(0.25),

                  // Handles 404, invalid image, network error, etc.
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: context.sh(0.25),
                      //width: double.infinity,
                      //color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            //color: Colors.grey.shade400,
                          ),
                          Text(
                            "No Image",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },

                  // Optional loading placeholder
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      height: context.sh(0.25),
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Gap(AppSpacing.lg),
              Text(
                products.first.name.toString(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(AppSpacing.md),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "AED ${products.first.ecommercePrice!.toStringAsFixed(2)} ",
                      style: context.tt.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    Text(
                      //products.first.listPrice.toString(),
                      "per ${products.first.uomName}",
                      style: context.tt.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(AppSpacing.lg),
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _infoCard("BARCODE", scannedBarcode),
                      Gap(AppSpacing.md),
                      _infoCard("REFERENCE", products.first.id.toString()),
                      Gap(AppSpacing.md),
                      _infoCard(
                        "STOCK",
                        products.first.qtyAvailable!.toStringAsFixed(2),
                        isGreen: true,
                      ),
                    ],
                  ),
                ),
              ),
              Gap(AppSpacing.xxxlg),
              _button(title: "Start With New Product Search"),
            ],
          ),
        ),
      ),
    );
  }

  Widget landScapeView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.network(
                        ApiPath.imageBaseUrl(products.first.image!),
                        height: context.sh(0.5),
                      ),
                    ),
                  ),
                  // Gap(AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            products.first.name.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "AED ${products.first.standardPrice.toString()} ",
                                style: context.tt.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ColorPalette.primaryColor,
                                ),
                              ),
                              Text(
                                products.first.listPrice.toString(),
                                style: context.tt.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                  color: ColorPalette.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Gap(AppSpacing.xxlg),
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _infoCard("BARCODE", scannedBarcode),
                      Gap(AppSpacing.md),
                      _infoCard("REFERENCE", products.first.id.toString()),
                      Gap(AppSpacing.md),
                      _infoCard("STOCK", "166 units", isGreen: true),
                    ],
                  ),
                ),
              ),
              Gap(AppSpacing.xxxlg),
              _button(title: "Start With New Product Search"),
            ],
          ),
        ),
      ),
    );
  }

  // Info CARD
  Widget _infoCard(String title, String value, {bool isGreen = false}) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.tt.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(AppSpacing.sm),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.tt.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button({required String title}) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
          );

          if (result != null) {
            log("Result : $result");
            scannedBarcode = result;
            fetchProduct(scannedBarcode);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primaryColor,
          foregroundColor: ColorPalette.whiteColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  void fetchProduct(String barcode) async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getProductByBarcode(barcode);
    if (result != null && result.data!.isNotEmpty) {
      products = result.data!;
      isLoading = false;
      setState(() {});
    } else if (result != null && result.data!.isEmpty) {
      setState(() {
        isLoading = false;
        emptyData = true;
      });

      // Future.delayed(const Duration(seconds: 10), () async {
      //   final result = await Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
      //   );
      //
      //   if (result != null) {
      //     log("Result : $result");
      //     scannedBarcode = result;
      //     fetchProduct(scannedBarcode);
      //   }
      // });
    } else {
      log("No product found");
    }
  }
}
