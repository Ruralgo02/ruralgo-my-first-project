import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ensures the user has a displayName and a Firestore profile.
/// Use after phone sign-in (and any other sign-in where name might be missing).
Future<void> ensureDisplayName(User user) async {
  final uid = user.uid;
  final users = FirebaseFirestore.instance.collection('users');
  final snap = await users.doc(uid).get();

  String? name;
  String? role;

  if (snap.exists) {
    final data = snap.data() as Map<String, dynamic>;
    name = (data['name'] as String?)?.trim();
    role = (data['role'] as String?)?.trim();
  }

  // Fallback name if none saved yet
  name ??= (user.email != null && user.email!.contains('@'))
      ? user.email!.split('@').first
      : 'RuralGo User';

  // Update FirebaseAuth displayName if empty
  if ((user.displayName ?? '').trim().isEmpty) {
    await user.updateDisplayName(name);
    await user.reload();
  }

  final Map<String, dynamic> payload = {
    'name': name,
    'phone': user.phoneNumber,
    'role': (role == null || role.isEmpty) ? 'user' : role,
  };

  if (user.email != null) {
    payload['email'] = user.email;
  }

  if (!snap.exists) {
    payload['createdAt'] = FieldValue.serverTimestamp();
  }

  await users.doc(uid).set(payload, SetOptions(merge: true));
}