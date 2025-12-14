import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:get/get.dart";
import "package:location/location.dart";
import "package:http/http.dart" as http;
import "../../../data/models/order_model.dart";

/// Экран выбора точки отправки заказа для продавца
class SellerPickupLocationScreen extends StatefulWidget {
  final OrderModel orderData;

  const SellerPickupLocationScreen({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  // Добавьте фабричный конструктор
  factory SellerPickupLocationScreen.fromArguments(dynamic arguments) {
    return SellerPickupLocationScreen(orderData: arguments as OrderModel);
  }

  @override
  _SellerPickupLocationScreenState createState() =>
      _SellerPickupLocationScreenState();
}

class _SellerPickupLocationScreenState
    extends State<SellerPickupLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Location _location = Location();
  LatLng? _currentPosition;
  LatLng _defaultPosition = LatLng(59.9343, 30.3351);
  Marker? _pickupMarker;
  bool _isLoading = false;
  // Тип карты: true - спутниковая, false - обычная
  bool _isSatelliteView = false;

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
        if (permissionGranted != PermissionStatus.granted &&
            permissionGranted != PermissionStatus.grantedLimited) return;
      }

      LocationData locationData = await _location.getLocation();
      final newPosition =
          LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _currentPosition = newPosition;
        _pickupMarker = Marker(
          point: newPosition,
          child: Icon(
            Icons.store,
            color: Colors.orange,
            size: 40,
          ),
        );
      });

      // Перемещаем карту к текущему местоположению
      _mapController.move(newPosition, 16.0);
    } catch (e) {
      print("Ошибка получения местоположения: $e");
      Get.snackbar(
        'Ошибка',
        'Не удалось определить местоположение. Проверьте разрешения GPS.',
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
          Icons.store,
          color: Colors.orange,
          size: 40,
        ),
      );
    });
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
                Icons.store,
                color: Colors.orange,
                size: 40,
              ),
            );
          });

          _mapController.move(newPosition, 15.0);
        }
      }
    } catch (e) {
      print("Ошибка поиска адреса: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmPickupLocation() {
    if (_pickupMarker == null) {
      Get.snackbar(
        'Ошибка',
        'Пожалуйста, выберите точку отправки на карте',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text("Подтвердить точку отправки",
            style: TextStyle(color: Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Вы уверены, что хотите отправить заказ с этой точки?",
                style: TextStyle(color: Colors.black)),
            SizedBox(height: 8),
            Text(
              "Координаты: ${_pickupMarker!.point.latitude.toStringAsFixed(6)}, ${_pickupMarker!.point.longitude.toStringAsFixed(6)}",
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Отмена", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переход к экрану статусов обработки заказа
              print(
                  '✅ Переход на экран статуса заказа с данными: ${widget.orderData.id}');
              Get.toNamed("/seller-order-status", arguments: widget.orderData);
            },
            child: Text("Подтвердить"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Выберите точку отправки"),
        backgroundColor: Colors.orange,
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
                urlTemplate: _isSatelliteView
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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

          /// Кнопки управления картой
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Кнопка переключения вида карты
                FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: () {
                    setState(() {
                      _isSatelliteView = !_isSatelliteView;
                    });
                  },
                  heroTag: 'map_type',
                  child: Icon(
                    _isSatelliteView ? Icons.map : Icons.satellite,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                /// Кнопка для получения текущего местоположения
                FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: _getCurrentLocation,
                  heroTag: 'my_location',
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),

          /// Кнопка "Подтвердить" отдельно от кнопок управления
          if (_pickupMarker != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: _confirmPickupLocation,
                backgroundColor: Colors.orange,
                icon: Icon(Icons.check),
                label: Text("Подтвердить"),
              ),
            ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
