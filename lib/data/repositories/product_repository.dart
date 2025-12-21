import '../sources/api/product_api.dart';
import '../../features/home/models/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> fetchProducts() async {
    return await ProductApi.fetchProducts();
  }

  Future<List<ProductModel>> getProducts() async {
    return await ProductApi.fetchProducts();
  }

  Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int qentity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    return await ProductApi.placeOrder(
      userId: userId,
      productId: productId,
      qentity: qentity,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }

  /// Добавление товара
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) async {
    return await ProductApi.addProduct(
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  /// Редактирование товара
  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) async {
    return await ProductApi.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  /// Удаление товара
  Future<bool> deleteProduct(int productId) async {
    return await ProductApi.deleteProduct(productId);
  }
}
