import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/styles/colors.dart';
import '../../../utils/device/screen_util.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesController favoritesController =
      Get.put(FavoritesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Избранное",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: KColors.primary,
      ),
      body: Obx(() {
        if (favoritesController.favoriteItems.isEmpty) {
          return Center(
            child: Text(
              "Избранное пусто",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView.builder(
          itemCount: favoritesController.favoriteItems.length,
          itemBuilder: (context, index) {
            final product = favoritesController.favoriteItems[index];
            return ListTile(
              leading: Image.asset(
                product['image'],
                width: ScreenUtil.adaptiveWidth(50),
                height: ScreenUtil.adaptiveHeight(50),
              ),
              title: Text(
                product['name'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                "${product['price']} ₽",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  favoritesController.removeFromFavorites(product);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
