import 'package:flutter/material.dart';

class RiderWalletPage extends StatelessWidget {
  static const routeName = '/rider-wallet';

  const RiderWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FBF6),
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: const Color(0xFF00A082),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF00A082),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  '₦0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Cash Earnings'),
              subtitle: const Text('Completed cash orders'),
              trailing: const Text(
                '₦0',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Settlement History'),
              subtitle: const Text('No settlement record yet'),
            ),
          ),
        ],
      ),
    );
  }
}