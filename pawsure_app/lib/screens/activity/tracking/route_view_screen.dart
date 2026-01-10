//lib/screens/activity/tracking/route_view_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pawsure_app/models/activity_log_model.dart';
import 'package:intl/intl.dart';

class RouteViewScreen extends StatefulWidget {
  final ActivityLog activity;

  const RouteViewScreen({super.key, required this.activity});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  LatLng? _centerPosition;

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeRoute() {
    if (widget.activity.routeData == null ||
        widget.activity.routeData!.isEmpty) {
      return;
    }

    // Convert route data to LatLng points
    final List<LatLng> routePoints = widget.activity.routeData!
        .map((point) => LatLng(point.lat, point.lng))
        .toList();

    // Set center position (middle of route)
    if (routePoints.isNotEmpty) {
      _centerPosition = routePoints[routePoints.length ~/ 2];
    }

    // Create polyline
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('saved_route'),
        points: routePoints,
        color: _getActivityColor(),
        width: 5,
      ),
    );

    // Add start marker
    if (routePoints.isNotEmpty) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: routePoints.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Start'),
        ),
      );

      // Add end marker (only if different from start)
      if (routePoints.length > 1) {
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: routePoints.last,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'End'),
          ),
        );
      }
    }
  }

  Color _getActivityColor() {
    switch (widget.activity.activityType.toLowerCase()) {
      case 'walk':
        return Colors.blue;
      case 'run':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _recenterMap() {
    if (_centerPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _centerPosition!, zoom: 15),
        ),
      );
    }
  }

  void _fitRouteBounds() {
    if (widget.activity.routeData == null ||
        widget.activity.routeData!.isEmpty ||
        _mapController == null) {
      return;
    }

    final points = widget.activity.routeData!;
    if (points.length < 2) return;

    // Calculate bounds
    double minLat = points.first.lat;
    double maxLat = points.first.lat;
    double minLng = points.first.lng;
    double maxLng = points.first.lng;

    for (var point in points) {
      if (point.lat < minLat) minLat = point.lat;
      if (point.lat > maxLat) maxLat = point.lat;
      if (point.lng < minLng) minLng = point.lng;
      if (point.lng > maxLng) maxLng = point.lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50px padding
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerPosition ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Fit route bounds after map is created
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitRouteBounds();
              });
            },
            polylines: _polylines,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Header with Activity Info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button Row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.activity.title ??
                                  widget.activity.activityType.capitalize!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'MMM d, yyyy • h:mm a',
                              ).format(widget.activity.activityDate),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: widget.activity.formattedDuration,
                      color: Colors.orange,
                    ),
                    if (widget.activity.distanceKm != null)
                      _buildStatColumn(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value:
                            '${widget.activity.distanceKm!.toStringAsFixed(2)} km',
                        color: Colors.green,
                      ),
                    if (widget.activity.caloriesBurned != null)
                      _buildStatColumn(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: widget.activity.caloriesBurned.toString(),
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Recenter Button
          Positioned(
            bottom: 32,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: _fitRouteBounds,
              child: const Icon(Icons.fit_screen, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
