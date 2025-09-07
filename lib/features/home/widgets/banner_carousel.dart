import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../utils/device/screen_util.dart';

class BannerCarousel extends StatelessWidget {
  final List<String> banners;

  const BannerCarousel({required this.banners});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: ScreenUtil.adaptiveHeight(170),
        autoPlayInterval: Duration(seconds: 5),
        autoPlay: true, // Автопрокрутка
        enlargeCenterPage: true, // Увеличение текущего элемента
        viewportFraction: 0.8, // Ширина элемента относительно экрана
      ),
      items: banners.map((banner) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil.adaptiveWidth(2)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(banner),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
