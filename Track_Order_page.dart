import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;
  const TrackOrderPage({super.key, required this.orderId});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  GoogleMapController? _map;

  LatLng? _rider;
  LatLng? _dropoff;

  bool _cameraMovedOnce = false;

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ IMPORTANT: Match Firestore collection name exactly (Orders vs orders)
    final orderRef =
        FirebaseFirestore.instance.collection("Orders").doc(widget.orderId);

    return Scaffold(
      appBar: AppBar(title: Text("Track Order ${widget.orderId}")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: orderRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text("Order not found in Firestore"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          // ✅ Must match your Firestore fields exactly
          final dLat = data["dropoffLat"];
          final dLng = data["dropoffLng"];
          final rLat = data["riderLiveLat"];
          final rLng = data["riderLiveLng"];

          if (dLat != null && dLng != null) {
            _dropoff = LatLng((dLat as num).toDouble(), (dLng as num).toDouble());
          }

          if (rLat != null && rLng != null) {
            _rider = LatLng((rLat as num).toDouble(), (rLng as num).toDouble());
          }

          final markers = <Marker>{
            if (_dropoff != null)
              Marker(
                markerId: const MarkerId("dropoff"),
                position: _dropoff!,
                infoWindow: const InfoWindow(title: "Drop-off"),
              ),
            if (_rider != null)
              Marker(
                markerId: const MarkerId("rider"),
                position: _rider!,
                infoWindow: const InfoWindow(title: "Rider"),
              ),
          };

          final start = _rider ?? _dropoff ?? const LatLng(9.0765, 7.3986);

          // ✅ Move camera smoothly when rider updates
          if (_map != null && _rider != null) {
            scheduleMicrotask(() async {
              if (!mounted) return;

              // first time: zoom nicely
              if (!_cameraMovedOnce) {
                _cameraMovedOnce = true;
                await _map!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _rider!, zoom: 16),
                  ),
                );
              } else {
                // later: just follow rider
                await _map!.animateCamera(CameraUpdate.newLatLng(_rider!));
              }
            });
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(target: start, zoom: 15),
            onMapCreated: (c) => _map = c,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}