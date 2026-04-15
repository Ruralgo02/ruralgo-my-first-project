import 'package:flutter/material.dart';

class ParcelSummaryPage extends StatelessWidget {
  static const routeName = '/parcel_summary';
  const ParcelSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Parcel Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pickup: ${args['pickupAddress']}'),
            const SizedBox(height: 8),
            Text('Drop-off: ${args['dropoffAddress']}'),
            const SizedBox(height: 8),
            Text('Receiver Phone: ${args['receiverPhone']}'),
            const SizedBox(height: 8),
            Text('Item: ${args['itemDescription']}'),
            const SizedBox(height: 20),
            const Text('Next step: Map → Price → Paystack → Dispatch'),
          ],
        ),
      ),
    );
  }
}