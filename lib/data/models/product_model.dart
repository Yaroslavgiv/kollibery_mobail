import '../../domain/entities/product_entity.dart';

/// DTO товара. Расширяет доменную сущность и умеет JSON.
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    required super.userId,
    required super.name,
    required super.description,
    required super.price,
    required super.quantityInStock,
    required super.category,
    required super.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : (rawId != null ? (int.tryParse(rawId.toString()) ?? 0) : 0);

    final rawPrice = json['price'];
    final price = rawPrice is int
        ? rawPrice.toDouble()
        : (rawPrice is num ? rawPrice.toDouble() : 0.0);

    return ProductModel(
      id: id,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      isDeleted: json['isDeleted'] ?? false,
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: price,
      quantityInStock: json['quantityInStock'] is int
          ? json['quantityInStock'] as int
          : int.tryParse('${json['quantityInStock']}') ?? 0,
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
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
