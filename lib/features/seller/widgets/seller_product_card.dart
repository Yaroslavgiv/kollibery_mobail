import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/themes/theme.dart';
import '../../../common/styles/colors.dart';
import '../../../features/home/models/product_model.dart';
import '../../../features/buyer/product_card/views/product_card_screen.dart';
import '../../../utils/device/screen_util.dart';
import '../../../utils/helpers/hex_image.dart';
import '../../../data/repositories/product_repository.dart';

class SellerProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onDeleted;

  const SellerProductCard({
    Key? key,
    required this.product,
    this.onDeleted,
  }) : super(key: key);

  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Удаление товара',
          style: TextStyle(color: Colors.black),
        ),
        content: Text(
          'Вы уверены, что хотите удалить товар "${product.name}"?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ProductRepository();
        final success = await repository.deleteProduct(product.id);
        if (success) {
          onDeleted?.call();
        } else {
        }
      } catch (e) {
      }
    }
  }

  void _openProductDetails(BuildContext context) {
    Get.to(() => ProductCardScreen(product: product));
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider = HexImage.resolveImageProvider(product.image);
    
    if (imageProvider == null) {
      imageProvider = const AssetImage('assets/logos/Logo_black.png');
    }

    return GestureDetector(
      onTap: () => _openProductDetails(context),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.white, // Фон для изображения
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain, // Показываем изображение полностью
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Ошибка загрузки изображения: $error');
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenUtil.adaptiveWidth(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TAppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: KColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  "${product.price} ₽",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.blue),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _deleteProduct(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

