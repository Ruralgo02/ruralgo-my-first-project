import 'package:flutter/material.dart';

class VendorStoreProfilePage extends StatelessWidget {
  static const routeName = '/vendor-store-profile';
  const VendorStoreProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Store Profile")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Store Profile page (Coming soon)\n\n"
          "Here you will edit business name, phone, location, delivery areas, etc.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}