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
      setState(() {
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        _pickupMarker = Marker(
          point: _currentPosition!,
          child: Icon(
            Icons.store,
            color: Colors.orange,
            size: 40,
          ),
        );
      });
    } catch (e) {
      print("Ошибка получения местоположения: $e");
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
        "Ошибка",
        "Выберите точку отправки на карте",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text("Подтвердить точку отправки"),
        content: Text("Вы уверены, что хотите отправить заказ с этой точки?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переход к экрану статусов обработки заказа
              Get.toNamed("/seller-order-status", arguments: widget.orderData);
            },
            child: Text("Подтвердить"),
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmPickupLocation,
        backgroundColor: Colors.orange,
        icon: Icon(Icons.check),
        label: Text("Подтвердить"),
      ),
    );
  }
}
