import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:get/get.dart";
import "package:location/location.dart";
import "package:http/http.dart" as http;
import "../../../data/models/order_model.dart";
import "../../../common/widgets/swipe_confirm_dialog.dart";

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
            Icons.navigation,
            color: Colors.blue,
            size: 40,
          ),
        );
      });

      // Перемещаем карту к текущему местоположению
      _mapController.move(newPosition, 16.0);
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
          Icons.navigation, // Иконка стрелочки вместо самолета
          color: Colors.blue,
          size: 40,
        ),
      );
    });
  }

  void _confirmPickupLocation() {
    if (_pickupMarker == null) {
      Get.snackbar(
        'Ошибка',
        'Пожалуйста, выберите точку посадки дрона на карте',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final point = _pickupMarker!.point;
    SwipeConfirmDialog.show(
      context: context,
      title: "Подтвердить точку посадки дрона",
      message: "Выбранные координаты:\nШирота: ${point.latitude.toStringAsFixed(6)}\nДолгота: ${point.longitude.toStringAsFixed(6)}\n\nВызвать дрон к этой точке?",
      confirmText: "Вызвать дрон",
      confirmColor: Colors.blue,
      icon: Icons.flight_takeoff,
      onConfirm: () {
        // Переход к экрану статусов отправки заказа
        Get.toNamed("/tech-delivery-status", arguments: widget.orderData);
      },
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
                  backgroundColor: Colors.blue,
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
                  backgroundColor: Colors.blue,
                  onPressed: _getCurrentLocation,
                  heroTag: 'my_location',
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          /// Кнопка "Подтвердить геолокацию" отдельно от кнопок управления
          if (_pickupMarker != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: _confirmPickupLocation,
                backgroundColor: Colors.blue,
                icon: Icon(Icons.check),
                label: Text("Подтвердить геолокацию"),
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
