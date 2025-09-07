import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/models/product_model.dart';
import '../../profile/views/delivery_point_screen.dart';
import '../../../utils/helpers/hex_image.dart';

class TechProductCardScreen extends StatelessWidget {
  final ProductModel product;
  TechProductCardScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    // Универсальный провайдер: Base64/HEX/HTTP/asset + безопасный фолбэк
    final imageProvider = HexImage.resolveImageProvider(product.image) ??
        const AssetImage('assets/logos/Logo_black.png');

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(product.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black)),
            SizedBox(height: 8),
            Text(product.description, style: TextStyle(color: Colors.black)),
            SizedBox(height: 8),
            Text('Цена: ${product.price} ₽',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Заказать как покупатель
                  Get.to(() => DeliveryPointScreen(role: 'tech_buyer'));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Заказать как покупатель',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
