import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final RxList<Map<String, dynamic>> favoriteItems =
      <Map<String, dynamic>>[].obs;

  void addToFavorites(Map<String, dynamic> product) {
    favoriteItems.add(product);
    Get.snackbar(
      "Успешно",
      "Товар добавлен в избранное",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeFromFavorites(Map<String, dynamic> product) {
    favoriteItems.remove(product);
    Get.snackbar(
      "Успешно",
      "Товар удалён из избранного",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
