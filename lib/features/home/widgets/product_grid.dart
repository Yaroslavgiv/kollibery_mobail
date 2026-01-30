import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/common/themes/theme.dart';
import '../../../../utils/device/screen_util.dart';
import '../../buyer/product_card/views/product_card_screen.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/models/product_model.dart';
import '../../../utils/helpers/hex_image.dart';

class ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final void Function(Map<String, dynamic> product)? onProductTap;
  final bool showCartButton; // Параметр для показа/скрытия кнопки корзины

  const ProductGrid({
    Key? key,
    required this.products,
    this.onProductTap,
    this.showCartButton = true, // По умолчанию показываем корзину
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ScreenUtil.adaptiveWidth(10),
        mainAxisSpacing: ScreenUtil.adaptiveHeight(10),
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        try {
          final productMap = products[index];
          
          // Безопасное преобразование типов
          final rawId = productMap['id'];
          final id = rawId is int
              ? rawId
              : (rawId != null ? (int.tryParse(rawId.toString()) ?? 0) : 0);
          
          final rawPrice = productMap['price'];
          final price = (rawPrice is num)
              ? rawPrice.toDouble()
              : (rawPrice != null ? (double.tryParse(rawPrice.toString()) ?? 0.0) : 0.0);
          
          final rawQuantity = productMap['quantityInStock'];
          final quantityInStock = rawQuantity is int
              ? rawQuantity
              : (rawQuantity != null ? (int.tryParse(rawQuantity.toString()) ?? 0) : 0);
          
          final product = ProductModel(
            id: id,
            createdAt: productMap['createdAt']?.toString() ?? '',
            updatedAt: productMap['updatedAt']?.toString() ?? '',
            isDeleted: productMap['isDeleted'] ?? false,
            userId: productMap['userId']?.toString() ?? '',
            name: productMap['name']?.toString() ?? '',
            description: productMap['description']?.toString() ?? '',
            price: price,
            quantityInStock: quantityInStock,
            category: productMap['category']?.toString() ?? '',
            image: productMap['image']?.toString() ?? '',
          );

          // Универсальное определение провайдера изображения
          ImageProvider imageProvider =
              HexImage.resolveImageProvider(product.image) ??
                  const AssetImage('assets/logos/Logo_black.png');

          return GestureDetector(
          onTap: () {
            if (onProductTap != null) {
              onProductTap!(productMap);
            } else {
              // Переход на экран карточки товара по умолчанию (покупатель)
              Get.to(() => ProductCardScreen(product: product));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: TAppTheme.lightTheme.hintColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil.adaptiveWidth(6),
                      left: ScreenUtil.adaptiveWidth(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TAppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${product.price} ₽",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.blue),
                      ),
                      SizedBox(height: 4),
                      // Кнопка добавления в корзину (только для покупателя)
                      if (showCartButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add_shopping_cart,
                                color: Colors.green, size: 20),
                            onPressed: () {
                              try {
                                final cartController = Get.find<CartController>();
                                cartController.addToCart(product.toJson());
                              } catch (e) {
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        } catch (e, stackTrace) {
          print('❌ Ошибка при отображении товара $index: $e');
          print('Stack trace: $stackTrace');
          // Возвращаем заглушку при ошибке
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(height: 8),
                  Text(
                    'Ошибка загрузки',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
