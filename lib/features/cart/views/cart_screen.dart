import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../../orders/views/order_details_screen.dart';
import '../controllers/cart_controller.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Корзина"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Корзина пуста",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  "Добавьте товары для оформления заказа",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListView.builder(
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartController.cartItems[index];
                    return ListTile(
                      leading: Image.asset(
                        product['image'],
                        width: ScreenUtil.adaptiveWidth(50),
                        height: ScreenUtil.adaptiveHeight(50),
                      ),
                      title: Text(
                        product['name'],
                        style: TAppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        "${product['price']} ₽",
                        style: TAppTheme.lightTheme.textTheme.labelMedium,
                      ),
                      onTap: () {
                        Get.to(() => OrderDetailsScreen(
                              imageUrl: product['image'],
                              name: product['name'],
                              description: product['description'],
                              price: product['price'],
                              productId: product['id'] ?? 1,
                            ));
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cartController.removeFromCart(product);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            // Кнопка оформления заказа
            Container(
              padding: EdgeInsets.all(18.0),
              child: ElevatedButton(
                onPressed: () {
                  _showOrderConfirmation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Оформить заказ (${cartController.cartItems.length} товар${_getPluralForm(cartController.cartItems.length)})",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showOrderConfirmation() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text("Подтверждение заказа"),
        content: Text(
            "Вы хотите оформить заказ на ${cartController.cartItems.length} товар${_getPluralForm(cartController.cartItems.length)}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToOrder();
            },
            child: Text("Оформить"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToOrder() {
    // Передаем данные о товарах из корзины
    final cartItems = cartController.cartItems;
    if (cartItems.isNotEmpty) {
      // Берем первый товар для примера (в реальном приложении можно обработать все)
      final product = cartItems.first;
      final productData = {
        'id': product['id'] ?? 1,
        'name': product['name'],
        'description': product['description'],
        'price': product['price'],
        'image': product['image'],
        'quantity': cartItems.length,
        'fromCart': true,
      };

      Get.toNamed('/delivery-point', arguments: {
        'role': 'buyer', // Всегда как покупатель при заказе товара
        'productData': productData,
      });
    }
  }

  String _getPluralForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return '';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'а';
    } else {
      return 'ов';
    }
  }
}
