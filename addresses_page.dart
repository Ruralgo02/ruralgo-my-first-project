import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'select_address_map_page.dart';

class AddressesPage extends StatefulWidget {
  static const routeName = '/addresses';
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('addresses');

  Future<void> _openAddOrEditSheet({
    required String uid,
    String? docId,
    Map<String, dynamic>? data,
  }) async {
    final isEdit = docId != null;

    final labelCtrl =
        TextEditingController(text: (data?['label'] ?? '').toString());
    final addressCtrl =
        TextEditingController(text: (data?['address'] ?? '').toString());
    final noteCtrl =
        TextEditingController(text: (data?['note'] ?? '').toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEdit ? 'Edit address' : 'Add new address',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Save delivery points for faster checkout'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Label (e.g., Home, Work)',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Full address',
                  hintText: 'Street, area, city, state',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Delivery instructions (optional)',
                  hintText: 'Landmark, gate code, directions...',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final label = labelCtrl.text.trim();
                    final address = addressCtrl.text.trim();
                    final note = noteCtrl.text.trim();

                    if (label.isEmpty || address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Label and address are required'),
                        ),
                      );
                      return;
                    }

                    final payload = {
                      'label': label,
                      'address': address,
                      'note': note,
                      'updatedAt': FieldValue.serverTimestamp(),
                      if (!isEdit) 'createdAt': FieldValue.serverTimestamp(),
                      if (!isEdit) 'isDefault': false,
                    };

                    if (isEdit) {
                      await _col(uid).doc(docId).update(payload);
                    } else {
                      await _col(uid).add(payload);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEdit ? 'Save changes' : 'Save address',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setDefault(String uid, String selectedId) async {
    final batch = FirebaseFirestore.instance.batch();
    final snap = await _col(uid).get();

    for (final d in snap.docs) {
      batch.update(d.reference, {'isDefault': d.id == selectedId});
    }
    await batch.commit();
  }

  Future<void> _deleteAddress(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }

  Future<void> _addFromMap(String uid) async {
    final result = await Navigator.pushNamed(
      context,
      SelectAddressMapPage.routeName,
    );

    if (!mounted) return;
    if (result == null || result is! Map) return;

    final data = Map<String, dynamic>.from(result);

    await _col(uid).add({
      'label': (data['label'] ?? 'Other').toString(),
      'address': (data['fullAddress'] ?? data['title'] ?? '').toString(),
      'note': (data['moreInfo'] ?? '').toString(),
      'title': (data['title'] ?? '').toString(),
      'subtitle': (data['subtitle'] ?? '').toString(),
      'fullAddress': (data['fullAddress'] ?? '').toString(),
      'lat': data['lat'],
      'lng': data['lng'],
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'isDefault': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Addresses'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _brandGreen,
              onPressed: () => _openAddOrEditSheet(uid: user.uid),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
      body: user == null
          ? const Center(child: Text('Please sign in to manage addresses.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  _col(user.uid).orderBy('updatedAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 60,
                            color: _brandGreen,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No saved addresses yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add Home/Work addresses to checkout faster.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _openAddOrEditSheet(uid: user.uid),
                              child: const Text(
                                'Add your first address',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _addFromMap(user.uid),
                              child: const Text('Pick on map'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    final data = d.data();
                    final label = (data['label'] ?? '').toString();
                    final address = (data['address'] ?? '').toString();
                    final note = (data['note'] ?? '').toString();
                    final isDefault = (data['isDefault'] ?? false) == true;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x3300A082)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _brandGreen.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDefault ? Icons.star : Icons.place_outlined,
                            color: _brandGreen,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _brandGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _brandGreen,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address),
                              if (note.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Note: $note',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'default') {
                              await _setDefault(user.uid, d.id);
                            } else if (v == 'edit') {
                              await _openAddOrEditSheet(
                                uid: user.uid,
                                docId: d.id,
                                data: data,
                              );
                            } else if (v == 'delete') {
                              await _deleteAddress(user.uid, d.id);
                            } else if (v == 'map') {
                              await _addFromMap(user.uid);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Set as default'),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem(
                              value: 'map',
                              child: Text('Add from map'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}