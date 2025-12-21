import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import 'tech_products_screen.dart';
import 'tech_orders_screen.dart';
import 'tech_dronebox_screen.dart';
import '../../../common/widgets/swipe_confirm_dialog.dart';

class TechMainScreen extends StatefulWidget {
  @override
  _TechMainScreenState createState() => _TechMainScreenState();
}

class _TechMainScreenState extends State<TechMainScreen> {
  int _selectedIndex = 0;
  final GetStorage box = GetStorage();
  final AuthController authController = Get.find<AuthController>();

  final List<Widget> _screens = [
    TechProductsScreen(),
    TechOrdersScreen(),
    TechDroneboxScreen(),
  ];

  String _getRoleDisplayName() {
    final role = box.read('role') ?? 'tech';
    switch (role) {
      case 'buyer':
        return 'Покупатель';
      case 'seller':
        return 'Продавец';
      case 'tech':
        return 'Техник';
      default:
        return 'Техник';
    }
  }

  /// Показывает диалог подтверждения выхода
  void _showLogoutDialog() {
    SwipeConfirmDialog.show(
      context: context,
      title: "Выход из аккаунта",
      message: "Вы уверены, что хотите выйти из аккаунта?",
      confirmText: "Выйти",
      confirmColor: Colors.red,
      icon: Icons.logout,
      onConfirm: () {
        authController.logout();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Роль: ${_getRoleDisplayName()}'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Товары',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Дронбокс',
          ),
        ],
      ),
    );
  }
}
