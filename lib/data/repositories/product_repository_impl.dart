import '../../domain/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../sources/api/product_api.dart';

/// Реализация репозитория товаров.
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts() {
    return ProductApi.fetchProducts();
  }

  @override
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) {
    return ProductApi.addProduct(
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  @override
  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) {
    return ProductApi.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  @override
  Future<bool> deleteProduct(int productId) {
    return ProductApi.deleteProduct(productId);
  }
}
