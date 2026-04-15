import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/address_service.dart';

class SelectAddressMapPage extends StatefulWidget {
  static const routeName = '/select-address-map';

  const SelectAddressMapPage({super.key});

  @override
  State<SelectAddressMapPage> createState() => _SelectAddressMapPageState();
}

class _SelectAddressMapPageState extends State<SelectAddressMapPage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);
  static const Color _softBorder = Color(0x2200A082);
  static const Color _chipBg = Color(0xFFDDF7F0);

  GoogleMapController? _mapController;

  LatLng _selected = const LatLng(9.0765, 7.3986);

  bool _loading = false;

  String _title = "Search for a place";
  String _subtitle = "";
  String _full = "";

  final TextEditingController _searchCtrl = TextEditingController();

  String _label = "Home";

  @override
  void initState() {
    super.initState();
    _initMyLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selected = LatLng(position.latitude, position.longitude);

      await _reverseGeocode(_selected);
      _moveCamera(_selected, zoom: 16);
    } catch (_) {
      await _reverseGeocode(_selected);
    }
  }

  Future<void> _searchAndMove() async {
    final query = _searchCtrl.text.trim();

    if (query.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        setState(() {
          _loading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location not found")),
        );
        return;
      }

      final loc = locations.first;
      final target = LatLng(loc.latitude, loc.longitude);

      _selected = target;

      await _reverseGeocode(target);
      _moveCamera(target, zoom: 17);
    } catch (_) {
      setState(() {
        _loading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to search this address")),
      );
    }
  }

  void _moveCamera(LatLng target, {double zoom = 16}) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() {
      _loading = true;
      _title = "Fetching address...";
      _subtitle = "";
      _full = "";
    });

    try {
      final placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);

      if (placemarks.isEmpty) {
        setState(() {
          _loading = false;
          _title = "Unknown place";
          _subtitle = "";
          _full = "";
        });
        return;
      }

      final pm = placemarks.first;

      final name = _best([pm.name, pm.street]);
      final area = _best([pm.subLocality, pm.locality]);
      final city = _best([pm.locality, pm.administrativeArea]);

      final title =
          name.isNotEmpty ? name : (area.isNotEmpty ? area : "Selected place");

      final subtitle = [
        if (area.isNotEmpty) area,
        if (city.isNotEmpty && city != area) city,
      ].join(", ");

      final full = [
        pm.name,
        pm.street,
        pm.subLocality,
        pm.locality,
        pm.administrativeArea,
        pm.country,
      ].where((e) => (e ?? "").trim().isNotEmpty).join(", ");

      setState(() {
        _loading = false;
        _title = title;
        _subtitle = subtitle;
        _full = full;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _title = "Unable to fetch address";
        _subtitle = "";
        _full = "";
      });
    }
  }

  String _best(List<String?> items) {
    for (final item in items) {
      if (item != null && item.trim().isNotEmpty) {
        return item.trim();
      }
    }
    return "";
  }

  Future<void> _saveAddress() async {
    await AddressService.saveAddress(
      label: _label,
      title: _title,
      subtitle: _subtitle,
      fullAddress: _full,
      lat: _selected.latitude,
      lng: _selected.longitude,
      moreInfo: "",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Address saved")),
    );
  }

  void _confirmAndReturn() {
    final result = {
      "label": _label,
      "title": _title,
      "subtitle": _subtitle,
      "fullAddress": _full,
      "moreInfo": "",
      "displayAddress": _full,
      "lat": _selected.latitude,
      "lng": _selected.longitude,
    };

    Navigator.pop(context, result);
  }

  Widget _labelChip(String label) {
    final selected = _label == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _label = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _chipBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _brandGreen : Colors.black12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check,
                  size: 16,
                  color: _brandGreen,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? _brandGreen : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canConfirm =>
      !_loading &&
      _title.isNotEmpty &&
      _title != "Search for a place" &&
      _title != "Fetching address..." &&
      _title != "Unable to fetch address";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _brandBg,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selected,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onCameraMove: (position) {
              _selected = position.target;
            },
            onCameraIdle: () {
              _reverseGeocode(_selected);
            },
          ),

          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 135),
              child: Icon(
                Icons.location_pin,
                size: 54,
                color: Colors.red,
              ),
            ),
          ),

          Positioned(
            top: 48,
            left: 18,
            right: 18,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(18),
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchAndMove(),
                      decoration: InputDecoration(
                        hintText: "Search address",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _searchAndMove,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: _brandGreen),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: 300,
            child: Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _initMyLocation,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.my_location,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 14,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(
                        width: 42,
                        child: Divider(
                          thickness: 4,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Confirm delivery address",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        _labelChip("Home"),
                        const SizedBox(width: 10),
                        _labelChip("Office"),
                        const SizedBox(width: 10),
                        _labelChip("Other"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _brandBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _softBorder),
                      ),
                      child: _loading
                          ? const Row(
                              children: [
                                SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Fetching address...",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Selected address",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (_subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _subtitle,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _canConfirm ? _confirmAndReturn : null,
                        child: const Text(
                          "Confirm Address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandGreen,
                          side: const BorderSide(color: _brandGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _canConfirm ? _saveAddress : null,
                        child: const Text(
                          "Save Address",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}