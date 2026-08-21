import '../../data/models/product_model.dart';
import '../repositories/product_repository.dart';

/// Бизнес-сценарии каталога.
class ProductService {
  ProductService(this._repository);

  final ProductRepository _repository;

  Future<List<ProductModel>> getCatalog() => _repository.getProducts();

  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) {
    return _repository.addProduct(
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
    return _repository.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      quantityInStock: quantityInStock,
      category: category,
      image: image,
    );
  }

  Future<bool> deleteProduct(int productId) =>
      _repository.deleteProduct(productId);
}
