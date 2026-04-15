import 'package:flutter/material.dart';

// ✅ Map address picker page
import 'select_address_map_page.dart';

// ✅ Universal checkout page
import 'checkout_page.dart';

class ParcelsBookingPage extends StatefulWidget {
  const ParcelsBookingPage({super.key, required this.serviceName});

  static const routeName = '/parcels-booking';

  final String serviceName;

  @override
  State<ParcelsBookingPage> createState() => _ParcelsBookingPageState();
}

class _ParcelsBookingPageState extends State<ParcelsBookingPage> {
  final _formKey = GlobalKey<FormState>();

  final _pickupCtrl = TextEditingController();
  final _dropOffCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();

  Map<String, dynamic>? _pickup;
  Map<String, dynamic>? _dropoff;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropOffCtrl.dispose();
    _phoneCtrl.dispose();
    _itemCtrl.dispose();
    super.dispose();
  }

  // ===================== MAP PICKER =====================

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> _pickOnMap({required bool isPickup}) async {
    final result = await Navigator.pushNamed(
      context,
      SelectAddressMapPage.routeName,
    );

    if (result is! Map) return;

    final address = (result["address"] ?? "").toString().trim();
    final lat = _toDouble(result["lat"]);
    final lng = _toDouble(result["lng"]);

    // If map page returned incomplete data, do nothing (avoid crash)
    if (address.isEmpty || lat == null || lng == null) {
      _snack("Could not read location. Please pick again.");
      return;
    }

    final picked = {
      "address": address,
      "lat": lat,
      "lng": lng,
    };

    if (!mounted) return;

    setState(() {
      if (isPickup) {
        _pickup = picked;
        _pickupCtrl.text = address;
      } else {
        _dropoff = picked;
        _dropOffCtrl.text = address;
      }
    });
  }

  // ===================== SUBMIT =====================

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_pickup == null) {
      _snack("Please select pickup location on map.");
      return;
    }

    if (_dropoff == null) {
      _snack("Please select drop-off location on map.");
      return;
    }

    final payload = {
      "pickup": {
        "name": "Pickup",
        "phone": _phoneCtrl.text.trim(),
        "landmark": _pickup!["address"],
        "directions": "Lat: ${_pickup!["lat"]}, Lng: ${_pickup!["lng"]}",
        "lat": _pickup!["lat"],
        "lng": _pickup!["lng"],
      },
      "dropoff": {
        "name": "Drop-off",
        "phone": _phoneCtrl.text.trim(),
        "landmark": _dropoff!["address"],
        "directions": "Lat: ${_dropoff!["lat"]}, Lng: ${_dropoff!["lng"]}",
        "lat": _dropoff!["lat"],
        "lng": _dropoff!["lng"],
      },
      "item": _itemCtrl.text.trim(),
      "serviceName": widget.serviceName,
    };

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    Navigator.pushNamed(
      context,
      CheckoutPage.routeName,
      arguments: {
        "orderType": "parcel",
        "orderId": orderId,
        "payload": payload,
      },
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF6EEF4);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.serviceName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book a pickup & delivery',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),

              _TapInputBox(
                controller: _pickupCtrl,
                hint: 'Pickup address (tap to choose on map)',
                onTap: () => _pickOnMap(isPickup: true),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Select pickup address' : null,
              ),
              const SizedBox(height: 12),

              _TapInputBox(
                controller: _dropOffCtrl,
                hint: 'Drop-off address (tap to choose on map)',
                onTap: () => _pickOnMap(isPickup: false),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Select drop-off address' : null,
              ),
              const SizedBox(height: 12),

              _InputBox(
                controller: _phoneCtrl,
                hint: 'Receiver phone number',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Enter receiver phone number';
                  if (s.length < 8) return 'Phone number too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _InputBox(
                controller: _itemCtrl,
                hint: 'What are we picking? (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Continue to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== INPUT WIDGETS =====================

class _TapInputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _TapInputBox({
    required this.controller,
    required this.hint,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(Icons.map_outlined),
        filled: true,
        fillColor: Colors.white.withOpacity(0.75),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputBox({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.75),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}