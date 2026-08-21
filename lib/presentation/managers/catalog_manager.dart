import 'package:get/get.dart';

import '../../data/models/product_model.dart';
import '../../domain/services/product_service.dart';

/// Manager каталога. Единственная точка входа UI к товарам.
class CatalogManager extends GetxController {
  CatalogManager({ProductService? productService})
      : _productService = productService ?? Get.find<ProductService>();

  final ProductService _productService;

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<List<ProductModel>> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await _productService.getCatalog();
      products.assignAll(list);
      return list;
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) {
    return _productService.addProduct(
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) {
    return _productService.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  Future<bool> deleteProduct(int productId) {
    return _productService.deleteProduct(productId);
  }
}
