import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  static const routeName = '/wallet';
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  String _selected = "cash"; // cash | transfer | card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("Wallet / Payment"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Choose your default payment method",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "This will be used at checkout. You can change it anytime.",
            style: TextStyle(color: Colors.black.withOpacity(0.65), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          _payOption(
            value: "cash",
            title: "Cash",
            subtitle: "Pay the rider when your order arrives.",
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 10),

          _payOption(
            value: "transfer",
            title: "Bank Transfer",
            subtitle: "Transfer to RuralGo account and confirm payment.",
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 10),

          _payOption(
            value: "card",
            title: "Card",
            subtitle: "Pay instantly using card (connect gateway later).",
            icon: Icons.credit_card_outlined,
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _brandGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _brandGreen.withOpacity(0.25)),
            ),
            child: Text(
              "Selected: ${_labelFor(_selected)}",
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Saved default payment: ${_labelFor(_selected)}")),
                );
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() => _selected = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _brandGreen.withOpacity(0.6) : Colors.black12,
            width: selected ? 1.4 : 1,
          ),
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
              child: Icon(icon, color: _brandGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.65))),
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

  String _labelFor(String v) {
    switch (v) {
      case "cash":
        return "Cash";
      case "transfer":
        return "Bank Transfer";
      case "card":
        return "Card";
      default:
        return v;
    }
  }
}