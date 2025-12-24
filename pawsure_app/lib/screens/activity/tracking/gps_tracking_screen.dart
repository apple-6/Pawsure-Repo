// lib/screens/activity/tracking/gps_tracking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/models/activity_log_model.dart' as models;

class GPSTrackingScreen extends StatefulWidget {
  const GPSTrackingScreen({super.key});

  @override
  State<GPSTrackingScreen> createState() => _GPSTrackingScreenState();
}

class _GPSTrackingScreenState extends State<GPSTrackingScreen> {
  final ActivityController _activityController = Get.find<ActivityController>();
  final PetController _petController = Get.find<PetController>();

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  final List<LatLng> _routePoints = [];
  final List<models.RoutePoint> _routeData = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  bool _isTracking = false;
  bool _isPaused = false;
  bool _hasFinished = false;
  bool _isFirstPoint = true; // NEW: Track if this is the first GPS point
  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  LatLng? _currentPosition;
  LatLng? _lastPosition;
  DateTime? _lastUpdateTime; // NEW: Track time between updates

  models.ActivityType _selectedType = models.ActivityType.walk;

  // Teleport detection threshold (meters)
  static const double _maxReasonableSpeed = 150.0; // 150 m/s = 540 km/h
  static const double _minDistanceToCount = 2.0; // Ignore movements < 2 meters

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _cleanupTracking();
    _mapController?.dispose();
    super.dispose();
  }

  void _cleanupTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _initializeLocation();
    } else {
      if (mounted) {
        Get.snackbar(
          'Permission Required',
          'Location permission is needed for GPS tracking',
          backgroundColor: Colors.red.withValues(alpha: 0.1),
        );
      }
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 16),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      if (mounted) {
        Get.snackbar(
          'Location Error',
          'Failed to get current location. Make sure GPS is enabled.',
          backgroundColor: Colors.red.withValues(alpha: 0.1),
        );
      }
    }
  }

  void _startTracking() {
    if (_currentPosition == null) {
      Get.snackbar('Error', 'Waiting for GPS location...');
      return;
    }

    setState(() {
      _isTracking = true;
      _isPaused = false;
      _hasFinished = false;
      _isFirstPoint = true; // Reset first point flag
      _routePoints.clear();
      _routeData.clear();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _lastPosition = null; // IMPORTANT: Reset to null
      _lastUpdateTime = null;

      // Don't add starting point yet - wait for first real GPS update
      _markers.clear();
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (_isTracking && !_isPaused && mounted) {
              _updatePosition(position);
            }
          },
          onError: (error) {
            debugPrint('❌ GPS stream error: $error');
            if (mounted) {
              Get.snackbar(
                'GPS Error',
                'Lost GPS signal. Pausing tracking.',
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
              );
              _pauseTracking();
            }
          },
        );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking && !_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _updatePosition(Position position) {
    final newPosition = LatLng(position.latitude, position.longitude);
    final now = DateTime.now();

    if (!mounted) return;

    // FIRST POINT: Just save it, don't calculate distance
    if (_isFirstPoint || _lastPosition == null) {
      setState(() {
        _isFirstPoint = false;
        _currentPosition = newPosition;
        _lastPosition = newPosition;
        _lastUpdateTime = now;

        // Add starting point
        _routePoints.add(newPosition);
        _routeData.add(
          models.RoutePoint(
            lat: position.latitude,
            lng: position.longitude,
            timestamp: now,
          ),
        );

        // Add start marker
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: newPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
      debugPrint(
        '📍 First GPS point set: ${newPosition.latitude}, ${newPosition.longitude}',
      );
      return;
    }

    // Calculate distance from last point
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    // TELEPORT GUARD: Check if movement is physically possible
    final timeDiff = now.difference(_lastUpdateTime!).inSeconds;
    final speed = timeDiff > 0 ? distance / timeDiff : 0;

    if (distance > 500) {
      // Massive jump (> 500m) - definitely a teleport
      debugPrint(
        '⚠️ TELEPORT DETECTED: ${distance.toStringAsFixed(1)}m jump. Ignoring.',
      );
      setState(() {
        _lastPosition = newPosition;
        _lastUpdateTime = now;
      });
      return;
    }

    if (speed > _maxReasonableSpeed && timeDiff < 10) {
      // Impossible speed detected
      debugPrint(
        '⚠️ Impossible speed: ${speed.toStringAsFixed(1)} m/s. Ignoring.',
      );
      setState(() {
        _lastPosition = newPosition;
        _lastUpdateTime = now;
      });
      return;
    }

    if (distance < _minDistanceToCount) {
      // Too small to count (GPS jitter)
      return;
    }

    // VALID MOVEMENT - Add it
    setState(() {
      _currentPosition = newPosition;
      _routePoints.add(newPosition);
      _routeData.add(
        models.RoutePoint(
          lat: position.latitude,
          lng: position.longitude,
          timestamp: now,
        ),
      );

      _totalDistance += distance / 1000; // Convert to km
      _lastPosition = newPosition;
      _lastUpdateTime = now;

      // Update polyline
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  void _pauseTracking() {
    if (!mounted) return;
    setState(() => _isPaused = true);
  }

  void _resumeTracking() {
    if (!mounted) return;
    setState(() {
      _isPaused = false;
      _lastUpdateTime =
          DateTime.now(); // Reset time to avoid speed calculation issues
    });
  }

  void _stopTracking() {
    _cleanupTracking();

    if (!mounted) return;

    setState(() {
      _isTracking = false;
      _isPaused = false;
      _hasFinished = true;

      if (_currentPosition != null && _routePoints.length > 1) {
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'End'),
          ),
        );
      }
    });
  }

  void _cancelTracking() {
    _cleanupTracking();
    if (mounted) {
      Get.back();
    }
  }

  Future<void> _saveActivity() async {
    if (_routePoints.length < 2 || _elapsedSeconds < 10) {
      Get.snackbar(
        'Insufficient Data',
        'Activity too short to save. Must be at least 10 seconds with movement.',
      );
      return;
    }

    final pet = _petController.selectedPet.value;
    if (pet == null) {
      Get.snackbar('Error', 'No pet selected');
      return;
    }

    final result = await Get.dialog<Map<String, dynamic>>(
      _buildSaveDialog(),
      barrierDismissible: false,
    );

    if (result != null && mounted) {
      final payload = {
        'activity_type': _selectedType.name,
        'title': result['title'],
        'description': result['description'],
        'duration_minutes': (_elapsedSeconds / 60).round(),
        'distance_km': _totalDistance,
        'calories_burned': _estimateCalories(),
        'activity_date': DateTime.now().toIso8601String(),
        'route_data': _routeData.map((e) => e.toJson()).toList(),
      };

      await _activityController.createActivity(pet.id, payload);
      if (mounted) {
        Get.back();
      }
    }
  }

  int _estimateCalories() {
    final durationMinutes = _elapsedSeconds / 60;
    double caloriesPerMinute;

    switch (_selectedType) {
      case models.ActivityType.walk:
        caloriesPerMinute = 3.5;
        break;
      case models.ActivityType.run:
        caloriesPerMinute = 8.0;
        break;
      case models.ActivityType.play:
        caloriesPerMinute = 5.0;
        break;
      case models.ActivityType.swim:
        caloriesPerMinute = 7.0;
        break;
      case models.ActivityType.training:
        caloriesPerMinute = 4.0;
        break;
      default:
        caloriesPerMinute = 4.0;
    }

    return (durationMinutes * caloriesPerMinute).round();
  }

  Widget _buildSaveDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    models.ActivityType selectedTypeLocal = _selectedType;

    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissal
      child: AlertDialog(
        title: const Text('Save Activity'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<models.ActivityType>(
                    value: selectedTypeLocal,
                    decoration: const InputDecoration(
                      labelText: 'Activity Type',
                      border: OutlineInputBorder(),
                    ),
                    items: models.ActivityType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedTypeLocal = value;
                        });
                        _selectedType = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back(
                result: {
                  'title': titleController.text.isNotEmpty
                      ? titleController.text
                      : null,
                  'description': descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : null,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isTracking && !_hasFinished) {
          final shouldExit = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Exit Tracking?'),
              content: const Text(
                'You have an active tracking session. Are you sure you want to exit?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Continue Tracking'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _cleanupTracking();
                    Get.back(result: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(0, 0),
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition!),
                  );
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: _polylines,
              markers: _markers,
              zoomControlsEnabled: false,
            ),

            // Stats Overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        icon: Icons.timer,
                        label: 'Time',
                        value: _formatDuration(_elapsedSeconds),
                      ),
                      _buildStatColumn(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value: '${_totalDistance.toStringAsFixed(2)} km',
                      ),
                      _buildStatColumn(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: _estimateCalories().toString(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Control Buttons
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  if (_isTracking && !_hasFinished) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isPaused ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPaused ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPaused ? 'Paused' : 'Tracking...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_isTracking && !_hasFinished) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _startTracking,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _cancelTracking,
                                icon: const Icon(Icons.close),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ] else if (_isTracking && !_hasFinished) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isPaused
                                    ? _resumeTracking
                                    : _pauseTracking,
                                icon: Icon(
                                  _isPaused ? Icons.play_arrow : Icons.pause,
                                ),
                                label: Text(_isPaused ? 'Resume' : 'Pause'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _stopTracking,
                                icon: const Icon(Icons.stop),
                                label: const Text('Finish'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ] else if (_hasFinished) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveActivity,
                                icon: const Icon(Icons.save),
                                label: const Text('Save Activity'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _cancelTracking,
                                icon: const Icon(Icons.delete),
                                label: const Text('Discard'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
