import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RiderProfilePage extends StatefulWidget {
  static const routeName = '/rider-profile';

  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  static const String currentRiderId = "09129317342";

  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _vehicleTypeCtrl = TextEditingController();
  final _plateNumberCtrl = TextEditingController();
  final _serviceAreaCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _isOnline = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadRider();
  }

  Future<void> _loadRider() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Riders')
          .doc(currentRiderId)
          .get();

      final data = doc.data();
      if (data != null) {
        _fullNameCtrl.text = (data['fullName'] ?? '').toString();
        _phoneCtrl.text = (data['phone'] ?? '').toString();
        _emailCtrl.text = (data['email'] ?? '').toString();
        _vehicleTypeCtrl.text = (data['vehicleType'] ?? '').toString();
        _plateNumberCtrl.text = (data['plateNumber'] ?? '').toString();
        _serviceAreaCtrl.text = (data['serviceArea'] ?? '').toString();
        _isOnline = data['isOnline'] == true;
        _isVerified = data['isVerified'] == true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rider: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveRider() async {
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('Riders')
          .doc(currentRiderId)
          .set({
        'fullName': _fullNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'vehicleType': _vehicleTypeCtrl.text.trim(),
        'plateNumber': _plateNumberCtrl.text.trim(),
        'serviceArea': _serviceAreaCtrl.text.trim(),
        'isOnline': _isOnline,
        'isVerified': _isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _plateNumberCtrl.dispose();
    _serviceAreaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FBF6),
      appBar: AppBar(
        title: const Text('Profile / Settings'),
        backgroundColor: const Color(0xFF00A082),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _field(_fullNameCtrl, 'Full Name'),
                _field(_phoneCtrl, 'Phone'),
                _field(_emailCtrl, 'Email'),
                _field(_vehicleTypeCtrl, 'Vehicle Type'),
                _field(_plateNumberCtrl, 'Plate Number'),
                _field(_serviceAreaCtrl, 'Service Area'),
                SwitchListTile(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  title: const Text('Online'),
                ),
                SwitchListTile(
                  value: _isVerified,
                  onChanged: (v) => setState(() => _isVerified = v),
                  title: const Text('Verified'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveRider,
                    child: Text(_saving ? 'Saving...' : 'Save Profile'),
                  ),
                ),
              ],
            ),
    );
  }
}