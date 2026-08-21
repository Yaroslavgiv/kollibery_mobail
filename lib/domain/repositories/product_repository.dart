import '../../data/models/product_model.dart';

/// Контракт репозитория товаров.
abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  });

  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  });

  Future<bool> deleteProduct(int productId);
}
