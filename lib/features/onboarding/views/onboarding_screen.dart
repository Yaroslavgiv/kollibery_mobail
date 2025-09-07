import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kollibry/common/styles/colors.dart';

import '../../../utils/device/screen_util.dart';
import '../../../utils/constants/strings.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      OnboardingPage(
        title: Strings.onboardingTitle1,
        description: Strings.onboardingDescription1,
        imagePath: 'assets/images/onboarding1.png',
      ),
      OnboardingPage(
        title: Strings.onboardingTitle2,
        description: Strings.onboardingDescription2,
        imagePath: 'assets/images/onboarding1.png',
      ),
      OnboardingPage(
        title: Strings.onboardingTitle3,
        description: Strings.onboardingDescription3,
        imagePath: 'assets/images/onboarding1.png',
        isLastPage: true,
        onLastPageButtonPressed: () {
          Get.toNamed('/login'); // Переход на экран логина
        },
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // PageView для онбординг-страниц
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _controller.forward(from: 0); // Перезапуск анимации
            },
            children: _pages,
          ),
          // Индикатор страниц
          Positioned(
            bottom: ScreenUtil.adaptiveHeight(25),
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.adaptiveWidth(10)),
                    width: _currentIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? KColors.accent
                          : KColors.backgroundLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
