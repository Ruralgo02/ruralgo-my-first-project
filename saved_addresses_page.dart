import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/address_service.dart';
import 'select_address_map_page.dart';

class SavedAddressesPage extends StatelessWidget {
  static const routeName = "/saved-addresses";

  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Addresses"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: AddressService.getAddresses(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No saved addresses"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(

                leading: const Icon(Icons.location_on),

                title: Text(
                  data["title"] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(data["subtitle"] ?? ""),

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    AddressService.deleteAddress(doc.id);
                  },
                ),

                onTap: () {

                  AddressService.markAsUsed(doc.id);

                  Navigator.pop(context, {
                    "title": data["title"],
                    "subtitle": data["subtitle"],
                    "fullAddress": data["fullAddress"],
                    "lat": data["lat"],
                    "lng": data["lng"],
                  });
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, SelectAddressMapPage.routeName);
        },
      ),
    );
  }
}