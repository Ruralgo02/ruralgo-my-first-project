import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTestPage extends StatefulWidget {
  static const String routeName = '/map-test';

  const MapTestPage({super.key});

  @override
  State<MapTestPage> createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage> {
  static const LatLng nigeriaCenter = LatLng(9.0820, 8.6753);

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Key _mapKey = UniqueKey();

  @override
  void dispose() {
    // Nothing special to dispose for GoogleMapController directly,
    // but keeping lifecycle clean prevents platform-view issues.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Test'),
      ),
      body: GoogleMap(
        key: _mapKey,
        initialCameraPosition: const CameraPosition(
          target: nigeriaCenter,
          zoom: 6,
        ),
        onMapCreated: (GoogleMapController c) {
          if (!_controller.isCompleted) {
            _controller.complete(c);
          }
        },

        // ✅ Keep these ON if you already granted runtime location permission.
        // If you haven’t implemented permission request yet, set both to false.
        myLocationEnabled: true,
        myLocationButtonEnabled: true,

        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}