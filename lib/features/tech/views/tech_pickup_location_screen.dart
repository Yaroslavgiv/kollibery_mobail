import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:get_storage/get_storage.dart";
import "package:latlong2/latlong.dart";
import "package:get/get.dart";
import "package:location/location.dart";
import "package:http/http.dart" as http;
import "../../../common/styles/colors.dart";
import "../../../data/models/order_model.dart";

/// Экран выбора точки посадки дрона для техника
class TechPickupLocationScreen extends StatefulWidget {
  final OrderModel orderData;

  const TechPickupLocationScreen({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  // Фабричный конструктор
  factory TechPickupLocationScreen.fromArguments(dynamic arguments) {
    return TechPickupLocationScreen(orderData: arguments as OrderModel);
  }

  @override
  _TechPickupLocationScreenState createState() =>
      _TechPickupLocationScreenState();
}

class _TechPickupLocationScreenState extends State<TechPickupLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Location _location = Location();
  LatLng? _currentPosition;
  LatLng _defaultPosition = LatLng(59.9343, 30.3351);
  Marker? _pickupMarker;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await _location.getLocation();
      final newPosition =
          LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _currentPosition = newPosition;
        _pickupMarker = Marker(
          point: newPosition,
          child: Icon(
            Icons.navigation,
            color: Colors.blue,
            size: 40,
          ),
        );
      });

      // Перемещаем карту к текущему местоположению
      _mapController.move(newPosition, 16.0);

      Get.snackbar(
        'Местоположение определено',
        'Текущее местоположение: ${newPosition.latitude.toStringAsFixed(6)}, ${newPosition.longitude.toStringAsFixed(6)}',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Ошибка получения местоположения: $e");
      Get.snackbar(
        'Ошибка',
        'Не удалось получить текущее местоположение',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _pickupMarker = Marker(
        point: point,
        child: Icon(
          Icons.navigation, // Иконка стрелочки вместо самолета
          color: Colors.blue,
          size: 40,
        ),
      );
    });

    // Показываем диалог с координатами и кнопками "Отмена" и "Вызвать дрон"
    _showDroneCallDialog(point);
  }

  void _showDroneCallDialog(LatLng point) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Подтвердить точку посадки дрона",
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Выбранные координаты:",
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              "Широта: ${point.latitude.toStringAsFixed(6)}",
              style: TextStyle(color: Colors.black87),
            ),
            Text(
              "Долгота: ${point.longitude.toStringAsFixed(6)}",
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Отмена",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переход к экрану статусов отправки заказа
              Get.toNamed("/tech-delivery-status", arguments: widget.orderData);
            },
            child: Text("Вызвать дрон"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          "https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(_searchController.text)}&limit=1",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]["lat"]);
          final lon = double.parse(data[0]["lon"]);
          final newPosition = LatLng(lat, lon);

          setState(() {
            _pickupMarker = Marker(
              point: newPosition,
              child: Icon(
                Icons.navigation, // Иконка стрелочки вместо самолета
                color: Colors.blue,
                size: 40,
              ),
            );
          });

          _mapController.move(newPosition, 15.0);

          // Показываем диалог после поиска адреса
          _showDroneCallDialog(newPosition);
        }
      }
    } catch (e) {
      print("Ошибка поиска адреса: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Выберите точку посадки дрона"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultPosition,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.kollibry",
              ),
              if (_pickupMarker != null) MarkerLayer(markers: [_pickupMarker!]),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Поиск адреса...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _searchAddress,
                      icon: Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Кнопка определения местоположения
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      // Убираем floatingActionButton с кнопкой "Подтвердить"
    );
  }
}
