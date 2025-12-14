import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadCartItems();

// Автоматическое сохранение при изменении данных
    ever(cartItems, (_) => saveCartItems());
  }

  void addToCart(Map<String, dynamic> product) {
    cartItems.add(product);
  }

  void removeFromCart(Map<String, dynamic> product) {
    cartItems.remove(product);
  }

  /// Удаление товара из корзины по ID товара
  void removeFromCartById(int productId) {
    final index = cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      cartItems.removeAt(index);
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in cartItems) {
      final price = item['price'];
      if (price is num) {
        total += price.toDouble();
      } else if (price is String) {
        total += double.tryParse(price) ?? 0.0;
      }
    }
    return total;
  }

  void saveCartItems() {
    storage.write('cartItems', cartItems);
  }

  void loadCartItems() {
    final storedItems = storage.read<List<dynamic>>('cartItems') ?? [];
    cartItems.assignAll(storedItems.cast<Map<String, dynamic>>());
  }

  void clearCart() {
    cartItems.clear();
    storage.remove('cartItems');
  }
}
