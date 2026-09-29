class ProductDetails {
  final int? success;
  final List<Product>? data;

  ProductDetails({this.success, this.data});

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      success: json['success'],
      data: (json['data'] as List?)
          ?.map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
  final int? id;
  final String? name;
  final String? displayName;
  final String? description;
  final String? image;
  final double? listPrice;
  final double? standardPrice;
  final double? partnerPrice;
  final double? ecommercePrice;
  final double? qtyAvailable;
  final String? uomName;

  Product({
    this.id,
    this.name,
    this.displayName,
    this.description,
    this.image,
    this.listPrice,
    this.standardPrice,
    this.ecommercePrice,
    this.partnerPrice,
    this.qtyAvailable,
    this.uomName
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      description: json['description'],
      image: json['image_1024'],
      listPrice: (json['list_price'] as num?)?.toDouble(),
      standardPrice: (json['standard_price'] as num?)?.toDouble(),
      ecommercePrice: (json['ecommerce_price'] as num?)?.toDouble(),
      partnerPrice: (json['partner_price'] as num?)?.toDouble(),
      qtyAvailable: (json['qty_available'] as num?)?.toDouble(),
      uomName: json['uom_name'],
    );
  }
}