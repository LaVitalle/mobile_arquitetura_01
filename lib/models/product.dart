class Product {
  final int? id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  const Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      title: (json['title'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      image: (json['image'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    };
  }

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}
