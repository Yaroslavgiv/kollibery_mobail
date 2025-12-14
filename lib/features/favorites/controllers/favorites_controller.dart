import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final RxList<Map<String, dynamic>> favoriteItems =
      <Map<String, dynamic>>[].obs;

  void addToFavorites(Map<String, dynamic> product) {
    favoriteItems.add(product);
  }

  void removeFromFavorites(Map<String, dynamic> product) {
    favoriteItems.remove(product);
  }
}
