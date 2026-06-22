class Product {
  final String id;
  final String merchantId;
  final String name;
  double price;
  int stock;
  final String category;
  List<String> allergens; // codes: SF, ML, EG, NT, GL, SY, CH
  final String imageUrl;
  bool isActive;

  Product({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.allergens,
    required this.imageUrl,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      category: json['category'] as String,
      allergens: List<String>.from(json['allergens'] ?? []),
      imageUrl: json['image_url'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'allergens': allergens,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  Product copyWith({
    double? price,
    int? stock,
    List<String>? allergens,
    bool? isActive,
  }) {
    return Product(
      id: this.id,
      merchantId: this.merchantId,
      name: this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: this.category,
      allergens: allergens ?? List.from(this.allergens),
      imageUrl: this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
