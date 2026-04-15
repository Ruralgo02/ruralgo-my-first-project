import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ParcelSize { small, large }
enum VehicleType { bike, smallVehicle, van, truck }

class ParcelsPage extends StatefulWidget {
  static const String routeName = '/parcels';
  const ParcelsPage({super.key});

  @override
  State<ParcelsPage> createState() => _ParcelsPageState();
}

class _ParcelsPageState extends State<ParcelsPage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _softBg = Color(0xFFE9FBF6);

  final _pickupName = TextEditingController();
  final _pickupPhone = TextEditingController();
  final _pickupWhatsapp = TextEditingController();
  final _pickupLandmark = TextEditingController();
  final _pickupStopPoint = TextEditingController();

  final _dropName = TextEditingController();
  final _dropPhone = TextEditingController();
  final _dropWhatsapp = TextEditingController();
  final _dropLandmark = TextEditingController();
  final _dropStopPoint = TextEditingController();

  ParcelSize _size = ParcelSize.small;
  VehicleType _vehicle = VehicleType.bike;
  bool _needLoadingHelp = false;
  bool _detailsSaved = false;
  bool _delivered = false;

  final _pickupKey = GlobalKey();
  final _dropKey = GlobalKey();

  @override
  void dispose() {
    _pickupName.dispose();
    _pickupPhone.dispose();
    _pickupWhatsapp.dispose();
    _pickupLandmark.dispose();
    _pickupStopPoint.dispose();

    _dropName.dispose();
    _dropPhone.dispose();
    _dropWhatsapp.dispose();
    _dropLandmark.dispose();
    _dropStopPoint.dispose();
    super.dispose();
  }

  Future<void> _call(String phone) async {
    final clean = phone.replaceAll(' ', '').trim();
    if (clean.isEmpty) {
      _snack('Phone number is empty.');
      return;
    }

    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Cannot place call on this device.');
    }
  }

  Future<void> _whatsapp(String number, String message) async {
    final clean = number.replaceAll(' ', '').trim();
    if (clean.isEmpty) {
      _snack('WhatsApp number is empty.');
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('WhatsApp is not available on this device.');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  void _submitDetails() {
    if (_pickupName.text.trim().isEmpty || _dropName.text.trim().isEmpty) {
      _snack("Please enter sender and receiver names.");
      return;
    }

    if (_pickupPhone.text.trim().isEmpty || _dropPhone.text.trim().isEmpty) {
      _snack("Please enter both sender and receiver phone numbers.");
      return;
    }

    setState(() {
      _detailsSaved = true;
    });

    _snack("Parcel request saved successfully.");
  }

  void _markDelivered() {
    if (!_detailsSaved) {
      _snack("Confirm parcel request first.");
      return;
    }

    setState(() {
      _delivered = true;
    });

    _snack("Delivery marked as complete.");
  }

  Future<void> _notifySenderDelivered() async {
    if (_pickupWhatsapp.text.trim().isEmpty) {
      _snack("Sender WhatsApp number is empty.");
      return;
    }

    final msg = '''
Hello ${_pickupName.text.trim().isEmpty ? "Customer" : _pickupName.text.trim()},

Your RuralGo parcel has been delivered successfully.

Receiver: ${_dropName.text.trim().isEmpty ? "-" : _dropName.text.trim()}
Delivery type: $_summaryLine
Drop-off landmark: ${_dropLandmark.text.trim().isEmpty ? "-" : _dropLandmark.text.trim()}
Stop point: ${_dropStopPoint.text.trim().isEmpty ? "-" : _dropStopPoint.text.trim()}

Thank you for choosing RuralGo.
''';

    await _whatsapp(_pickupWhatsapp.text, msg);
  }

  String get _summaryLine {
    final sizeLabel =
        _size == ParcelSize.small ? 'Small parcel' : 'Large parcel / relocation';

    final vehicleLabel = _vehicleLabel();

    final help =
        (_size == ParcelSize.large && _needLoadingHelp) ? ' • Loading help' : '';

    return '$sizeLabel • $vehicleLabel$help';
  }

  String _vehicleLabel() {
    switch (_vehicle) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.smallVehicle:
        return 'Small vehicle';
      case VehicleType.van:
        return 'Van';
      case VehicleType.truck:
        return 'Truck';
    }
  }

  void _setSize(ParcelSize s) {
    setState(() {
      _size = s;

      if (_size == ParcelSize.small) {
        if (_vehicle == VehicleType.van || _vehicle == VehicleType.truck) {
          _vehicle = VehicleType.smallVehicle;
        }
        _needLoadingHelp = false;
      } else {
        if (_vehicle == VehicleType.bike) {
          _vehicle = VehicleType.van;
        }
      }
    });
  }

  void _setVehicle(VehicleType v) {
    setState(() => _vehicle = v);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _brandGreen, width: 1.4),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType? type,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        decoration: _inputDeco(label, hint: hint),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: _brandGreen,
            side: BorderSide(color: _brandGreen.withOpacity(0.45)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceCard({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? _brandGreen.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: selected ? _brandGreen.withOpacity(0.55) : Colors.black12,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _brandGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _brandGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.60),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? _brandGreen : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget _servicesInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text(
              "Same-day dispatch",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text("Fast delivery within nearby communities."),
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.storefront),
            title: Text(
              "Market runs",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text("Pickup from market stalls and deliver to home."),
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.chair_alt),
            title: Text(
              "Relocation assistant",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text("Van or truck support for bulky items and moving."),
          ),
        ],
      ),
    );
  }
  Widget _contactCard({
    required String title,
    required GlobalKey sectionKey,
    required TextEditingController nameCtrl,
    required TextEditingController phoneCtrl,
    required TextEditingController whatsappCtrl,
    required TextEditingController landmarkCtrl,
    required TextEditingController stopCtrl,
    required String whatsappMessage,
  }) {
    return Container(
      key: sectionKey,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _field(
            title == "Sender details" ? "Sender name" : "Receiver name",
            nameCtrl,
            hint: title == "Sender details" ? "e.g. Mr John" : "e.g. Mrs Helen",
          ),
          _field(
            "Phone number",
            phoneCtrl,
            type: TextInputType.phone,
            hint: "e.g. 08012345678",
          ),
          _field(
            "WhatsApp number",
            whatsappCtrl,
            type: TextInputType.phone,
            hint: "e.g. 2348012345678",
          ),
          _field(
            "Landmark / nearby place",
            landmarkCtrl,
            hint: "e.g. Opposite the primary school",
          ),
          _field(
            "Where should the rider stop?",
            stopCtrl,
            hint: "e.g. Main gate, beside the shop, by the junction",
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _pillButton(
                icon: Icons.call,
                label: "Call",
                onTap: () => _call(phoneCtrl.text),
              ),
              const SizedBox(width: 12),
              _pillButton(
                icon: Icons.chat,
                label: "WhatsApp",
                onTap: () => _whatsapp(whatsappCtrl.text, whatsappMessage),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        title: const Text("Parcel & Relocation"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Book parcel delivery or relocation support with clear pickup and drop-off instructions.",
            style: TextStyle(
              color: Colors.black.withOpacity(0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _pillButton(
                icon: Icons.my_location,
                label: "Pickup",
                onTap: () => _scrollTo(_pickupKey),
              ),
              const SizedBox(width: 12),
              _pillButton(
                icon: Icons.location_on_outlined,
                label: "Drop-off",
                onTap: () => _scrollTo(_dropKey),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _servicesInfoCard(),

          _sectionTitle("What are you sending?"),
          _choiceCard(
            selected: _size == ParcelSize.small,
            icon: Icons.inventory_2_outlined,
            title: "Small parcel",
            subtitle: "Documents, food packs, small bag, or light package.",
            onTap: () => _setSize(ParcelSize.small),
          ),
          const SizedBox(height: 12),
          _choiceCard(
            selected: _size == ParcelSize.large,
            icon: Icons.weekend_outlined,
            title: "Large parcel / relocation",
            subtitle: "Boxes, appliances, furniture, and moving support.",
            onTap: () => _setSize(ParcelSize.large),
          ),

          _sectionTitle("Choose vehicle"),
          _choiceCard(
            selected: _vehicle == VehicleType.bike,
            icon: Icons.pedal_bike_outlined,
            title: "Bike",
            subtitle: "Best for small parcels and quick delivery.",
            onTap: () => _setVehicle(VehicleType.bike),
          ),
          const SizedBox(height: 12),
          _choiceCard(
            selected: _vehicle == VehicleType.smallVehicle,
            icon: Icons.directions_car_filled_outlined,
            title: "Small vehicle",
            subtitle: "For multiple small items or medium delivery runs.",
            onTap: () => _setVehicle(VehicleType.smallVehicle),
          ),
          if (_size == ParcelSize.large) ...[
            const SizedBox(height: 12),
            _choiceCard(
              selected: _vehicle == VehicleType.van,
              icon: Icons.airport_shuttle_outlined,
              title: "Van",
              subtitle: "For cartons, appliances, and multiple bags.",
              onTap: () => _setVehicle(VehicleType.van),
            ),
            const SizedBox(height: 12),
            _choiceCard(
              selected: _vehicle == VehicleType.truck,
              icon: Icons.local_shipping_outlined,
              title: "Truck",
              subtitle: "For heavy loads, furniture, and relocation jobs.",
              onTap: () => _setVehicle(VehicleType.truck),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _brandGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _brandGreen.withOpacity(0.20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Need loading or relocation help?",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _brandGreen.withOpacity(0.95),
                      ),
                    ),
                  ),
                  Switch(
                    value: _needLoadingHelp,
                    activeColor: _brandGreen,
                    onChanged: (v) => setState(() => _needLoadingHelp = v),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: _brandGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _summaryLine,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle("Pickup and drop-off"),
          _contactCard(
            title: "Sender details",
            sectionKey: _pickupKey,
            nameCtrl: _pickupName,
            phoneCtrl: _pickupPhone,
            whatsappCtrl: _pickupWhatsapp,
            landmarkCtrl: _pickupLandmark,
            stopCtrl: _pickupStopPoint,
            whatsappMessage:
                "Hello, I'm a RuralGo rider. I'm trying to locate your pickup point. Please share directions.",
          ),
          const SizedBox(height: 14),
          _contactCard(
            title: "Receiver details",
            sectionKey: _dropKey,
            nameCtrl: _dropName,
            phoneCtrl: _dropPhone,
            whatsappCtrl: _dropWhatsapp,
            landmarkCtrl: _dropLandmark,
            stopCtrl: _dropStopPoint,
            whatsappMessage:
                "Hello, I'm a RuralGo rider. I'm trying to locate your drop-off point. Please share directions.",
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitDetails,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Confirm Parcel Request"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _markDelivered,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text("Mark Delivery Complete"),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _delivered ? _notifySenderDelivered : null,
              icon: const Icon(Icons.chat),
              label: const Text("Notify Sender on WhatsApp"),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}