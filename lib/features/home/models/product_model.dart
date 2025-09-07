class ProductModel {
  final int id;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String userId;
  final String name;
  final String description;
  final double price;
  final int quantityInStock;
  final String category;
  final String image;

  ProductModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantityInStock,
    required this.category,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print('Парсинг ProductModel из JSON: $json');

    final id = json['id'] ?? 0;
    final createdAt = json['createdAt'] ?? '';
    final updatedAt = json['updatedAt'] ?? '';
    final isDeleted = json['isDeleted'] ?? false;
    final userId = json['userId'] ?? '';
    final name = json['name'] ?? '';
    final description = json['description'] ?? '';
    final price = (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] ?? 0.0);
    final quantityInStock = json['quantityInStock'] ?? 0;
    final category = json['category'] ?? '';
    final image = json['image'] ?? '';

    print(
        'Создан ProductModel: id=$id, name=$name, price=$price, image=$image');

    return ProductModel(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      userId: userId,
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'quantityInStock': quantityInStock,
      'category': category,
      'image': image,
    };
  }
}
