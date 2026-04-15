import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ParcelsMapPage extends StatefulWidget {
  static const String routeName = '/parcels-map';

  const ParcelsMapPage({super.key});

  @override
  State<ParcelsMapPage> createState() => _ParcelsMapPageState();
}

class _ParcelsMapPageState extends State<ParcelsMapPage> {
  final _pickupQuery = TextEditingController();
  final _dropQuery = TextEditingController();

  @override
  void dispose() {
    _pickupQuery.dispose();
    _dropQuery.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMapsSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      _snack("Type a location first.");
      return;
    }

    // Works with Google Maps app if installed, otherwise browser
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack("Could not open Maps.");
    }
  }

  Future<void> _openDirections() async {
    final from = _pickupQuery.text.trim();
    final to = _dropQuery.text.trim();

    if (from.isEmpty || to.isEmpty) {
      _snack("Enter both pickup and drop-off to open directions.");
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${Uri.encodeComponent(from)}'
      '&destination=${Uri.encodeComponent(to)}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack("Could not open directions.");
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map Assist")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Use this to search locations or open directions. "
            "If rural roads are missing on Maps, rely on the landmark/directions on the Parcels page.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _pickupQuery,
            decoration: const InputDecoration(
              labelText: "Pickup location (name / village / landmark)",
              hintText: "e.g. LEA Secretariat Zone 6 Abuja",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleMapsSearch(_pickupQuery.text),
                  icon: const Icon(Icons.search),
                  label: const Text("Search pickup"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _dropQuery,
            decoration: const InputDecoration(
              labelText: "Drop-off location (name / village / landmark)",
              hintText: "e.g. Gwagwalada Market Abuja",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleMapsSearch(_dropQuery.text),
                  icon: const Icon(Icons.search),
                  label: const Text("Search drop-off"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions),
              label: const Text("Open Directions (Pickup → Drop-off)"),
            ),
          ),
        ],
      ),
    );
  }
}