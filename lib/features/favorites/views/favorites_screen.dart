import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/styles/colors.dart';
import '../../../common/themes/theme.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';
import '../controllers/favorites_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../buyer/product_card/views/product_card_screen.dart';
import '../../home/models/product_model.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesController favoritesController =
      Get.put(FavoritesController());
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Избранное",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (favoritesController.favoriteItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Избранное пусто",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  "Добавьте товары в избранное",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: favoritesController.favoriteItems.length,
          itemBuilder: (context, index) {
            final product = favoritesController.favoriteItems[index];

            // Используем универсальный провайдер изображений
            final imageProvider =
                HexImage.resolveImageProvider(product['image']) ??
                    const AssetImage('assets/logos/Logo_black.png');

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: Container(
                  width: ScreenUtil.adaptiveWidth(60),
                  height: ScreenUtil.adaptiveHeight(60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                title: Text(
                  product['name'],
                  style: TAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      "${product['price']} ₽",
                      style:
                          TAppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (product['description'] != null)
                      Text(
                        product['description'],
                        style:
                            TAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                onTap: () {
                  // Переход на экран карточки товара
                  final productModel = ProductModel(
                    id: product['id'],
                    createdAt: product['createdAt'] ?? '',
                    updatedAt: product['updatedAt'] ?? '',
                    isDeleted: product['isDeleted'] ?? false,
                    userId: product['userId'] ?? '',
                    name: product['name'],
                    description: product['description'],
                    price: product['price'],
                    quantityInStock: product['quantityInStock'] ?? 0,
                    category: product['category'] ?? '',
                    image: product['image'],
                  );
                  Get.to(() => ProductCardScreen(product: productModel));
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Кнопка добавления в корзину
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                      onPressed: () {
                        cartController.addToCart(product);
                      },
                    ),
                    // Кнопка удаления из избранного
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(product);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> product) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text("Удаление из избранного",
            style: TextStyle(color: Colors.black)),
        content: Text(
            "Вы уверены, что хотите удалить \"${product['name']}\" из избранного?",
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Отмена", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              favoritesController.removeFromFavorites(product);
            },
            child: Text("Удалить"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
