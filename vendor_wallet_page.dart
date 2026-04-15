import 'package:flutter/material.dart';

class VendorWalletPage extends StatelessWidget {
  static const routeName = '/vendor-wallet';
  const VendorWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet / Payouts")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Wallet page (Coming soon)\n\n"
          "Here vendor will track earnings, payouts, bank details.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}