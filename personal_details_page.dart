import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDetailsPage extends StatelessWidget {
  static const routeName = '/personal-details';
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        return Scaffold(
          appBar: AppBar(title: const Text("Personal Details")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _row("Name", (data['name'] ?? '').toString()),
                _row("Email", (data['email'] ?? '').toString()),
                _row("Phone", (data['phone'] ?? '').toString()),
                _row("Role", (data['role'] ?? 'user').toString()),
                _row("Email Verified", (data['emailVerified'] ?? false).toString()),
                _row("Phone Verified", (data['phoneVerified'] ?? false).toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(fontWeight: FontWeight.w900))),
          Expanded(child: Text(v.isEmpty ? "-" : v)),
        ],
      ),
    );
  }
}