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
        final productMap = products[index];
        final product = ProductModel(
          id: productMap['id'],
          createdAt: productMap['createdAt'] ?? '',
          updatedAt: productMap['updatedAt'] ?? '',
          isDeleted: productMap['isDeleted'] ?? false,
          userId: productMap['userId'] ?? '',
          name: productMap['name'],
          description: productMap['description'],
          price: productMap['price'],
          quantityInStock: productMap['quantityInStock'] ?? 0,
          category: productMap['category'] ?? '',
          image: productMap['image'],
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
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
      },
    );
  }
}
