//pawsure_app/lib/screens/activity/tracking/gps_tracking_screen.dart
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
  bool _isFirstPoint = true;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  double _totalDistance = 0.0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  LatLng? _currentPosition;
  models.ActivityType _selectedType = models.ActivityType.walk;

  static const double _maxReasonableSpeed = 50.0;
  static const double _minDistanceToCount = 0.5;
  static const double _teleportThreshold = 100.0;
  static const int _minTimeForValidUpdate = 2;

  // ✅ Only Walk and Run allowed
  final List<models.ActivityType> _allowedActivityTypes = [
    models.ActivityType.walk,
    models.ActivityType.run,
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    debugPrint('🧹 GPSTrackingScreen: dispose() called');
    _cleanupTracking();
    _mapController?.dispose();
    super.dispose();
  }

  void _cleanupTracking() {
    debugPrint('🧹 Cleaning up tracking resources...');
    _positionStream?.cancel();
    _positionStream = null;
    _timer?.cancel();
    _timer = null;
    debugPrint('✅ Cleanup complete');
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _initializeLocation();
    } else {
      if (!mounted) return;
      Get.snackbar(
        'Permission Required',
        'Location permission is needed for GPS tracking',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
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
      if (!mounted) return;
      Get.snackbar(
        'Location Error',
        'Failed to get current location. Make sure GPS is enabled.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }

  void _startTracking() {
    if (_currentPosition == null) {
      Get.snackbar('Error', 'Waiting for GPS location...');
      return;
    }

    debugPrint('🚀 Starting GPS tracking...');

    if (!mounted) return;
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _hasFinished = false;
      _isFirstPoint = true;
      _routePoints.clear();
      _routeData.clear();
      _totalDistance = 0.0;
      _elapsedSeconds = 0;
      _lastPosition = null;
      _lastUpdateTime = null;
      _markers.clear();
      _polylines.clear();
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (_isTracking && !_isPaused && !_hasFinished && mounted) {
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
          cancelOnError: false,
        );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking && !_isPaused && !_hasFinished && mounted) {
        setState(() => _elapsedSeconds++);
      } else if (!mounted) {
        timer.cancel();
      }
    });

    debugPrint('✅ GPS tracking started');
  }

  void _updatePosition(Position position) {
    if (!mounted) {
      debugPrint('⚠️ Widget not mounted, ignoring GPS update');
      return;
    }

    if (!_isTracking || _hasFinished) {
      debugPrint('⚠️ Ignoring GPS update (not tracking)');
      return;
    }

    final newPosition = LatLng(position.latitude, position.longitude);
    final now = DateTime.now();

    if (_isFirstPoint || _lastPosition == null) {
      debugPrint(
        '📍 FIRST GPS POINT: ${newPosition.latitude}, ${newPosition.longitude}',
      );

      if (!mounted) return;

      setState(() {
        _isFirstPoint = false;
        _currentPosition = newPosition;
        _lastPosition = position;
        _lastUpdateTime = now;

        _routePoints.add(newPosition);
        _routeData.add(
          models.RoutePoint(
            lat: position.latitude,
            lng: position.longitude,
            timestamp: now,
          ),
        );

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
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    final timeDiff = now.difference(_lastUpdateTime!).inSeconds;

    debugPrint(
      '🔍 GPS Update: distance=${distance.toStringAsFixed(2)}m, time=${timeDiff}s',
    );

    if (timeDiff < _minTimeForValidUpdate) {
      debugPrint('⏱️ Update too soon (${timeDiff}s), waiting...');
      return;
    }

    if (distance > _teleportThreshold) {
      debugPrint(
        '🚫 TELEPORT DETECTED: ${distance.toStringAsFixed(1)}m jump. Ignoring.',
      );
      if (!mounted) return;
      setState(() {
        _lastPosition = position;
        _lastUpdateTime = now;
      });
      return;
    }

    if (timeDiff > 0) {
      final speed = distance / timeDiff;
      final speedKmh = speed * 3.6;

      if (speed > _maxReasonableSpeed) {
        debugPrint(
          '🚫 Impossible speed: ${speed.toStringAsFixed(1)} m/s (${speedKmh.toStringAsFixed(1)} km/h). Ignoring.',
        );
        if (!mounted) return;
        setState(() {
          _lastPosition = position;
          _lastUpdateTime = now;
        });
        return;
      }

      debugPrint('✅ Speed: ${speedKmh.toStringAsFixed(2)} km/h');
    }

    if (distance < _minDistanceToCount) {
      debugPrint(
        '⏭️ Movement too small: ${distance.toStringAsFixed(2)}m. Ignoring.',
      );
      if (!mounted) return;
      setState(() {
        _lastPosition = position;
        _lastUpdateTime = now;
      });
      return;
    }

    debugPrint(
      '✅ VALID MOVEMENT: ${distance.toStringAsFixed(2)}m added to route',
    );

    if (!mounted) return;

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

      _totalDistance += distance / 1000;
      _lastPosition = position;
      _lastUpdateTime = now;

      debugPrint('📊 Total distance: ${_totalDistance.toStringAsFixed(3)} km');
      debugPrint('📍 Route points: ${_routePoints.length}');

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
    debugPrint('⏸️ Tracking paused');
    setState(() => _isPaused = true);
  }

  void _resumeTracking() {
    if (!mounted) return;
    debugPrint('▶️ Tracking resumed');
    setState(() {
      _isPaused = false;
      _lastUpdateTime = DateTime.now();
    });
  }

  void _stopTracking() {
    debugPrint('⏹️ Stopping tracking...');
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

    debugPrint('✅ Tracking stopped. Route points: ${_routePoints.length}');
  }

  void _cancelTracking() {
    debugPrint('❌ Canceling tracking...');
    _cleanupTracking();
    if (mounted) {
      Get.back();
    }
  }

  Future<void> _saveActivity() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('💾 Attempting to save activity...');
    debugPrint('   Route points: ${_routePoints.length}');
    debugPrint('   Elapsed time: ${_elapsedSeconds}s');
    debugPrint('   Total distance: ${_totalDistance.toStringAsFixed(3)} km');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (_routePoints.length < 2) {
      Get.snackbar(
        'No Route Recorded',
        'No GPS movement detected. Please ensure GPS is enabled and try moving around.',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (_elapsedSeconds < 5) {
      Get.snackbar(
        'Activity Too Short',
        'Activity must be at least 5 seconds long.',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_totalDistance < 0.01) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Low Distance Detected'),
          content: Text(
            'Only ${(_totalDistance * 1000).toStringAsFixed(1)} meters recorded.\n\n'
            'This might happen if:\n'
            '• GPS signal was weak\n'
            '• You were mostly stationary\n'
            '• Indoor tracking\n\n'
            'Do you still want to save?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Save Anyway'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
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
        'title': result['title'] ?? 'Tracked Activity',
        'description': result['description'],
        'duration_minutes': (_elapsedSeconds / 60).round(),
        'distance_km': _totalDistance,
        'calories_burned': _estimateCalories(),
        'activity_date': DateTime.now().toIso8601String(),
        'route_data': _routeData.map((e) => e.toJson()).toList(),
      };

      debugPrint('📤 Sending activity payload:');
      debugPrint('   Type: ${payload['activity_type']}');
      debugPrint('   Duration: ${payload['duration_minutes']} min');
      debugPrint('   Distance: ${payload['distance_km']} km');
      debugPrint('   Route points: ${_routeData.length}');

      try {
        await _activityController.createActivity(pet.id, payload);

        Get.snackbar(
          'Success!',
          'Activity saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _cleanupTracking();

        if (mounted) {
          Get.back();
        }
      } catch (e) {
        debugPrint('❌ Failed to save activity: $e');
        Get.snackbar(
          'Error',
          'Failed to save activity: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
      default:
        caloriesPerMinute = 4.0;
    }

    return (durationMinutes * caloriesPerMinute).round();
  }

  // ✅ FIXED: Only Walk and Run in save dialog
  Widget _buildSaveDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    models.ActivityType selectedTypeLocal = _selectedType;

    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text('Save Activity'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Only Walk and Run options
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _allowedActivityTypes.map((type) {
                        final isSelected = selectedTypeLocal == type;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedTypeLocal = type;
                            });
                            setState(() {
                              _selectedType = type;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (type == models.ActivityType.walk
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1))
                                  : null,
                              border: type == models.ActivityType.walk
                                  ? Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? (type == models.ActivityType.walk
                                            ? Colors.blue
                                            : Colors.orange)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  type == models.ActivityType.walk
                                      ? '🚶 '
                                      : '🏃 ',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
        debugPrint('🔙 Back button pressed');

        if (_isTracking && !_hasFinished) {
          debugPrint('⚠️ Tracking active, showing confirmation dialog');

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
                    debugPrint('🛑 User confirmed exit');
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

          final result = shouldExit ?? false;
          debugPrint('🔙 Dialog result: $result');

          if (result) {
            _cleanupTracking();
          }

          return result;
        }

        debugPrint('✅ Not tracking, cleaning up and allowing back');
        _cleanupTracking();
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
