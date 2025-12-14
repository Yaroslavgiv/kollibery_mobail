import 'package:get/get.dart';
import '../../../cart/controllers/cart_controller.dart';

class ProductCardController extends GetxController {
  final CartController cartController = Get.put(CartController());

  final isInCart = false.obs;
  final isInFavorites = false.obs;

  void toggleCartStatus(Map<String, dynamic> product) {
    if (isInCart.value) {
      cartController.removeFromCart(product);
    } else {
      cartController.addToCart(product);
    }
    isInCart.value = !isInCart.value;
  }

  void toggleFavoriteStatus() {
    isInFavorites.value = !isInFavorites.value;
  }
}
