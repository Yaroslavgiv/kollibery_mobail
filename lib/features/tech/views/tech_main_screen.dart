import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import 'tech_products_screen.dart';
import 'tech_orders_screen.dart';
import 'tech_drone_screen.dart';
import 'tech_dronebox_screen.dart';

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
    TechDroneScreen(),
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
      case 'technician':
        return 'Техник';
      default:
        return 'Техник';
    }
  }

  void _logout() {
    authController.logout();
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
            onPressed: _logout,
            tooltip: 'Выйти из аккаунта',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Покупатель',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Продавец',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Дрон',
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
