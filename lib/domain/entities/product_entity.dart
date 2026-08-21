/// Товар каталога. Не зависит от Flutter и JSON.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantityInStock,
    required this.category,
    required this.image,
    this.userId = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.isDeleted = false,
  });

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
}
