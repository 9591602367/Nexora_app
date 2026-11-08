import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GeofenceMapPage extends StatefulWidget {
  const GeofenceMapPage({super.key});

  @override
  State<GeofenceMapPage> createState() => _GeofenceMapPageState();
}

class _GeofenceMapPageState extends State<GeofenceMapPage> {
  // ─── MAP CONTROLLER ────────────────────────────────────────────────────────
  final MapController _mapController = MapController();

  // ─── LOCATION ──────────────────────────────────────────────────────────────
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  // ─── GEOFENCE ──────────────────────────────────────────────────────────────
  LatLng? _geofenceCenter;
  double _geofenceRadius = 500;
  bool _isInsideGeofence = false;
  bool _geofenceCreated = false;

  // ─── LOADING / ERROR ───────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _errorMessage;

  // ─── RADIUS OPTIONS ────────────────────────────────────────────────────────
  final List<double> _radiusOptions = [100, 250, 500, 1000, 2000];

  // ─── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  // ─── DISPOSE ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ─── INITIALIZE LOCATION ───────────────────────────────────────────────────
  Future<void> _initializeLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services are disabled. Please enable GPS.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permission was denied.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          'Location permission is permanently denied. '
              'Please enable it from Android Settings.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _geofenceCenter = currentLatLng;
        _isLoading = false;
      });

      // Move map to current location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentLatLng, 16);
      });

      _startLocationMonitoring();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to get your location.\n$e';
      });
    }
  }

  // ─── LOCATION MONITORING ───────────────────────────────────────────────────
  void _startLocationMonitoring() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
          if (!mounted) return;
          setState(() {
            _currentPosition = position;
          });
          _checkGeofence(position);
        });
  }

  // ─── CHECK GEOFENCE ────────────────────────────────────────────────────────
  void _checkGeofence(Position position) {
    if (!_geofenceCreated || _geofenceCenter == null) return;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _geofenceCenter!.latitude,
      _geofenceCenter!.longitude,
    );

    final currentlyInside = distance <= _geofenceRadius;

    if (currentlyInside != _isInsideGeofence) {
      setState(() {
        _isInsideGeofence = currentlyInside;
      });
      _showGeofenceStatus(currentlyInside);
    }
  }

  // ─── GEOFENCE STATUS MESSAGE ───────────────────────────────────────────────
  void _showGeofenceStatus(bool inside) {
    if (!mounted) return;
    final message = inside
        ? '✅ You have entered your safe zone.'
        : '⚠️ Warning: You have left your safe zone!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: inside ? Colors.green : Colors.red,
        content: Row(
          children: [
            Icon(
              inside ? Icons.check_circle : Icons.warning_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CREATE GEOFENCE ───────────────────────────────────────────────────────
  void _createGeofence() {
    if (_currentPosition == null) return;

    final center = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    setState(() {
      _geofenceCenter = center;
      _geofenceCreated = true;
      _isInsideGeofence = true;
    });

    _mapController.move(center, 16);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('✅ Safe zone created successfully!'),
      ),
    );
  }

  // ─── REMOVE GEOFENCE ───────────────────────────────────────────────────────
  void _removeGeofence() {
    setState(() {
      _geofenceCreated = false;
      _isInsideGeofence = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safe zone removed.'),
      ),
    );
  }

  // ─── CHANGE RADIUS ─────────────────────────────────────────────────────────
  void _changeRadius(double radius) {
    setState(() {
      _geofenceRadius = radius;
    });

    if (_currentPosition != null && _geofenceCreated) {
      _checkGeofence(_currentPosition!);
    }
  }

  // ─── CENTER ON USER ────────────────────────────────────────────────────────
  void _centerOnUser() {
    if (_currentPosition == null) return;
    _mapController.move(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      17,
    );
  }

  // ─── FORMAT RADIUS ─────────────────────────────────────────────────────────
  String _formatRadius(double radius) {
    if (radius >= 1000) {
      return '${(radius / 1000).toStringAsFixed(radius == 1000 ? 0 : 1)} km';
    }
    return '${radius.toInt()} m';
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geofence Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Create and monitor your safe zone',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  // ─── BODY ──────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) return _buildError();

    if (_currentPosition == null) {
      return const Center(
        child: Text(
          'Location unavailable',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // ── MAP ──────────────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            initialZoom: 16,
            minZoom: 3,
            maxZoom: 19,
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.nexora',
            ),

            // Geofence circle
            if (_geofenceCreated && _geofenceCenter != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _geofenceCenter!,
                    radius: _geofenceRadius,
                    useRadiusInMeter: true,
                    color: _isInsideGeofence
                        ? Colors.green.withOpacity(0.20)
                        : Colors.red.withOpacity(0.20),
                    borderColor:
                    _isInsideGeofence ? Colors.green : Colors.red,
                    borderStrokeWidth: 3,
                  ),
                ],
              ),

            // Geofence center marker
            if (_geofenceCreated && _geofenceCenter != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _geofenceCenter!,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),

            // Current location marker
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── STATUS CARD ──────────────────────────────────────────────────────
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildStatusCard(),
        ),

        // ── BOTTOM CONTROLS ──────────────────────────────────────────────────
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: _buildControls(),
        ),

        // ── CENTER BUTTON ────────────────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 220,
          child: FloatingActionButton(
            heroTag: 'centerLocation',
            backgroundColor: Colors.white,
            onPressed: _centerOnUser,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // ─── STATUS CARD ───────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final statusColor = !_geofenceCreated
        ? Colors.orange
        : _isInsideGeofence
        ? Colors.green
        : Colors.red;

    final statusText = !_geofenceCreated
        ? 'Safe zone not created'
        : _isInsideGeofence
        ? '✅ You are inside your safe zone'
        : '⚠️ You are outside your safe zone!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              !_geofenceCreated
                  ? Icons.location_off
                  : _isInsideGeofence
                  ? Icons.shield
                  : Icons.warning_rounded,
              color: statusColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _geofenceCreated
                      ? 'Safe zone radius: ${_formatRadius(_geofenceRadius)}'
                      : 'Tap below to create a safe zone',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM CONTROLS ───────────────────────────────────────────────────────
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Radius label
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.blueAccent),
              const SizedBox(width: 10),
              const Text(
                'Safe Zone Radius',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _formatRadius(_geofenceRadius),
                style: const TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Radius chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _radiusOptions.map((radius) {
                final selected = _geofenceRadius == radius;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_formatRadius(radius)),
                    selected: selected,
                    onSelected: (_) => _changeRadius(radius),
                    selectedColor: Colors.blueAccent,
                    backgroundColor: const Color(0xFF334155),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Create/Remove button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
              _geofenceCreated ? _removeGeofence : _createGeofence,
              icon: Icon(
                _geofenceCreated
                    ? Icons.delete_outline
                    : Icons.add_location_alt,
              ),
              label: Text(
                _geofenceCreated ? 'Remove Safe Zone' : 'Create Safe Zone',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _geofenceCreated ? Colors.redAccent : Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR SCREEN ──────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off,
                color: Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Unable to access location.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeLocation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}