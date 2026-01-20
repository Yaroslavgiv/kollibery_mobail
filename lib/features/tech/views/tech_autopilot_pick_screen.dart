import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../data/repositories/flight_repository.dart';

class TechAutopilotPickScreen extends StatefulWidget {
  @override
  State<TechAutopilotPickScreen> createState() =>
      _TechAutopilotPickScreenState();
}

class _TechAutopilotPickScreenState extends State<TechAutopilotPickScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lonCtrl = TextEditingController();
  final Location _location = Location();
  final FlightRepository _flightRepository = FlightRepository();

  LatLng _center = LatLng(59.9343, 30.3351);
  LatLng? _startPoint; // Точка старта (текущее местоположение)
  LatLng? _endPoint; // Точка посадки
  List<LatLng> _waypoints = []; // Промежуточные точки
  Marker? _currentLocationMarker; // Маркер текущего местоположения
  bool _sending = false;
  bool _isSatelliteMode =
      false; // Режим карты: false = схематичный, true = спутниковый
  bool _isAddingWaypoint = false; // Режим добавления промежуточной точки
  bool _isAddingEndPoint = false; // Режим добавления точки посадки

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool enabled = await _location.serviceEnabled();
      if (!enabled) enabled = await _location.requestService();
      var perm = await _location.hasPermission();
      if (perm == PermissionStatus.denied) {
        perm = await _location.requestPermission();
      }
      if (perm == PermissionStatus.granted ||
          perm == PermissionStatus.grantedLimited) {
        final data = await _location.getLocation();
        if (data.latitude != null && data.longitude != null) {
          final here = LatLng(data.latitude!, data.longitude!);
          setState(() {
            _center = here;
            _startPoint = here;
            // Маркер текущего местоположения (точка старта)
            _currentLocationMarker = Marker(
              point: here,
              width: 50,
              height: 75,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.my_location, color: Colors.blue, size: 32),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'СТАРТ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
          _mapController.move(here, 15);
        }
      }
    } catch (_) {}
  }

  void _onTap(TapPosition _, LatLng p) {
    if (_isAddingWaypoint) {
      // Добавляем промежуточную точку (режим остается активным для добавления следующих точек)
      setState(() {
        _waypoints.add(p);
        // Режим остается активным для добавления следующих точек
      });
      return;
    }

    if (_isAddingEndPoint) {
      // Устанавливаем точку посадки
      setState(() {
        _endPoint = p;
        _latCtrl.text = p.latitude.toStringAsFixed(6);
        _lonCtrl.text = p.longitude.toStringAsFixed(6);
        _isAddingEndPoint = false; // Отключаем режим после добавления
      });
      return;
    }

    // Если ни один режим не активен, ничего не делаем
  }

  Future<void> _sendCoords() async {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    setState(() => _sending = true);
    try {
      // Преобразуем промежуточные точки в формат для API
      List<Map<String, double>>? waypoints;
      if (_waypoints.isNotEmpty) {
        waypoints = _waypoints
            .map((point) => {
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                })
            .toList();
      }

      // Формируем точки маршрута: старт + промежуточные + финиш
      // Используем явный тип Map<String, double> для совместимости с API
      final Map<String, double> startPointMap = {
        'latitude': _startPoint!.latitude,
        'longitude': _startPoint!.longitude,
      };
      
      final Map<String, double> endPointMap = {
        'latitude': _endPoint!.latitude,
        'longitude': _endPoint!.longitude,
      };

      // Отправляем все точки в массиве в /flight/orderlocation
      final orderLocationResp = await _flightRepository.sendOrderLocation(
        startPoint: startPointMap,
        buyerPoint: endPointMap,
        waypoints: waypoints,
      );

      final orderLocationOk = orderLocationResp.statusCode >= 200 &&
          orderLocationResp.statusCode < 300;
      
      if (orderLocationOk) {
        Get.back();
      } else {
        // Показываем подробную информацию об ошибке
        print('Ошибка отправки маршрута:');
        print('Status Code: ${orderLocationResp.statusCode}');
        print('Response Body: ${orderLocationResp.body}');
        print('Response Headers: ${orderLocationResp.headers}');
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Сеть: $e',
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

    // Маркер точки старта
    if (_currentLocationMarker != null) {
      markers.add(_currentLocationMarker!);
    }

    // Маркеры промежуточных точек
    for (int i = 0; i < _waypoints.length; i++) {
      markers.add(
        Marker(
          point: _waypoints[i],
          width: 40,
          height: 30,
          child: Center(
            child: UnconstrainedBox(
              constrainedAxis: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Маркер точки посадки
    if (_endPoint != null) {
      markers.add(
        Marker(
          point: _endPoint!,
          width: 50,
          height: 65,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.place, color: Colors.red, size: 36),
              SizedBox(height: 2),
              UnconstrainedBox(
                constrainedAxis: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ФИНИШ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    final List<Polyline> polylines = [];
    final List<LatLng> routePoints = [];

    // Добавляем точку старта
    if (_startPoint != null) {
      routePoints.add(_startPoint!);
    }

    // Добавляем промежуточные точки
    routePoints.addAll(_waypoints);

    // Добавляем точку финиша
    if (_endPoint != null) {
      routePoints.add(_endPoint!);
    }

    // Создаем полилинию маршрута
    if (routePoints.length >= 2) {
      polylines.add(
        Polyline(
          points: routePoints,
          strokeWidth: 3.0,
          color: Colors.blue,
          borderStrokeWidth: 1.0,
          borderColor: Colors.white,
        ),
      );
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Маршрут автопилота'), backgroundColor: Colors.blue),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
                initialCenter: _center, initialZoom: 14, onTap: _onTap),
            children: [
              TileLayer(
                  urlTemplate: _isSatelliteMode
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kollibry'),
              // Линия маршрута
              PolylineLayer(polylines: _buildPolylines()),
              // Все маркеры точек
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          // Кнопка переключения режима карты
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isSatelliteMode = !_isSatelliteMode;
                });
              },
              child: Icon(
                _isSatelliteMode ? Icons.map : Icons.satellite,
                color: Colors.blue,
              ),
              tooltip:
                  _isSatelliteMode ? 'Схематичная карта' : 'Спутниковая карта',
            ),
          ),
          // Панель управления
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              color: Colors.grey[900],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Маршрут: ${_startPoint != null ? "Старт" : "—"} → ${_waypoints.length} промежуточных → ${_endPoint != null ? "Финиш" : "—"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isAddingEndPoint
                              ? null
                              : () {
                                  setState(() {
                                    _isAddingWaypoint = !_isAddingWaypoint;
                                    if (_isAddingWaypoint) {
                                      _isAddingEndPoint = false;
                                    }
                                  });
                                },
                          icon: Icon(
                              _isAddingWaypoint
                                  ? Icons.check
                                  : Icons.add_location,
                              size: 18),
                          label: Text(_isAddingWaypoint
                              ? 'Завершить'
                              : 'Добавить точку'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAddingWaypoint
                                ? Colors.green
                                : Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isAddingWaypoint
                              ? null
                              : () {
                                  setState(() {
                                    _isAddingEndPoint = !_isAddingEndPoint;
                                    if (_isAddingEndPoint) {
                                      _isAddingWaypoint = false;
                                    }
                                  });
                                },
                          icon: Icon(
                              _isAddingEndPoint ? Icons.check : Icons.flag,
                              size: 18),
                          label: Text(_isAddingEndPoint
                              ? 'Завершить'
                              : 'Точка посадки'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isAddingEndPoint ? Colors.green : Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_waypoints.isNotEmpty || _endPoint != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _waypoints.clear();
                                _endPoint = null;
                              });
                            },
                            icon: Icon(Icons.delete_outline, size: 18),
                            label: Text('Очистить'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        if (_endPoint != null)
                          ElevatedButton.icon(
                            onPressed: _sending ? null : _sendCoords,
                            icon: Icon(Icons.send, size: 18),
                            label: Text('Отправить'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    if (_isAddingWaypoint)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Режим добавления промежуточной точки активен. Нажмите на карту для добавления.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (_isAddingEndPoint)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Режим добавления точки посадки активен. Нажмите на карту для добавления.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_sending)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Отправка маршрута...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
