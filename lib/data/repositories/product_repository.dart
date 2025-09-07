import '../sources/api/product_api.dart';
import '../../features/home/models/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> fetchProducts() async {
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
}
