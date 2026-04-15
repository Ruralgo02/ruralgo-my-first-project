import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:paystack_payment/paystack_payment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/contact_actions.dart';

enum PaymentMethod { cash, card, transfer }

class CheckoutPage extends StatefulWidget {
  static const routeName = '/checkout';
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool specialHandling = false;
  int tip = 0;

  PaymentMethod _paymentMethod = PaymentMethod.cash;

  final TextEditingController _note = TextEditingController();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _customerPhone = TextEditingController();

  final TextEditingController _landmarkCtrl = TextEditingController();
  final TextEditingController _stopPointCtrl = TextEditingController();
  final TextEditingController _deliveryInstructionCtrl =
      TextEditingController();

  Map<String, dynamic>? _deliveryAddress;
  
static const String _paystackInitUrl =
    'http://127.0.0.1:3000/paystack/initialize';

static const String _paystackTransferUrl =
    'http://127.0.0.1:3000/paystack/assign-dva';

  @override
  void dispose() {
    _note.dispose();
    _customerName.dispose();
    _customerPhone.dispose();
    _landmarkCtrl.dispose();
    _stopPointCtrl.dispose();
    _deliveryInstructionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};

    final String orderId = (args['orderId'] as String?) ?? '';
    final String orderType = (args['orderType'] ?? 'goods').toString();

    final List<Map<String, dynamic>> items = _toItemList(args['items']);
    final int itemsTotal =
        _asInt(args['itemsTotal']) ?? _calcItemsTotal(items);

    final String vendorName = (args['vendorName'] ?? '').toString();
    final String riderName = (args['riderName'] ?? '').toString();
    final String riderPhone = (args['riderPhone'] ?? '').toString();

    const int deliveryFee = 800;
    const int serviceFee = 200;

    final int total = itemsTotal + deliveryFee + serviceFee + tip;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vendorName.isNotEmpty ? "Checkout • $vendorName" : "Checkout",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Delivery address"),
          const SizedBox(height: 10),
          _deliveryAddressCard(context),

          const SizedBox(height: 14),

          _sectionTitle("Delivery details"),
          const SizedBox(height: 10),
          _deliveryDetailsCard(),

          const SizedBox(height: 14),

          _sectionTitle("Your contact"),
          const SizedBox(height: 10),
          _customerContactCard(),

          const SizedBox(height: 14),

          _sectionTitle("Your items"),
          const SizedBox(height: 10),
          _itemsCard(items: items, itemsTotal: itemsTotal),

          const SizedBox(height: 14),

          _tileCard(
            icon: Icons.edit_note,
            title: "Delivery note",
            subtitle: "Optional note for rider/vendor (e.g. call on arrival).",
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openNoteSheet(context),
          ),

          const SizedBox(height: 10),

          _switchCard(
            icon: Icons.inventory_2_outlined,
            title: "Special handling?",
            subtitle: "Tick if you want careful handling (optional).",
            value: specialHandling,
            onChanged: (v) => setState(() => specialHandling = v),
          ),

          const SizedBox(height: 14),

          if (riderPhone.trim().isNotEmpty) ...[
            _sectionTitle("Rider"),
            const SizedBox(height: 10),
            _riderContactCard(
              name: riderName.isEmpty ? "Your rider" : riderName,
              phone: riderPhone,
            ),
            const SizedBox(height: 14),
          ],_sectionTitle("Payment"),
          const SizedBox(height: 10),
          _paymentCard(),

          const SizedBox(height: 10),

          _tileCard(
            icon: Icons.volunteer_activism_outlined,
            title: "Courier tip",
            subtitle: "Optional tip for rider.",
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openTipSheet(context),
          ),

          const SizedBox(height: 14),

          _sectionTitle("Summary"),
          const SizedBox(height: 10),
          _summaryCard(
            itemsTotal: itemsTotal,
            deliveryFee: deliveryFee,
            serviceFee: serviceFee,
            tip: tip,
            total: total,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: orderId.isEmpty
                  ? null
                  : () => _handlePay(
                        context,
                        orderId: orderId,
                        orderType: orderType,
                        total: total,
                        itemsTotal: itemsTotal,
                        items: items,
                        vendorName: vendorName,
                      ),
              child: Text(
                orderId.isEmpty ? "Missing Order ID" : _payButtonText(total),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _deliveryAddressCard(BuildContext context) {
    final has = _deliveryAddress != null;

    final title = has
        ? (_deliveryAddress!['title'] ?? 'Selected address').toString()
        : 'Select delivery address';

    final addr = has
        ? (_deliveryAddress!['fullAddress'] ??
                _deliveryAddress!['displayAddress'] ??
                _deliveryAddress!['subtitle'] ??
                '')
            .toString()
        : 'Tap to choose address on map';

    return Card(
      child: ListTile(
        leading: Icon(
          has ? Icons.location_on : Icons.location_on_outlined,
          size: 26,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(addr),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _pickDeliveryAddress(context),
      ),
    );
  }

  Future<void> _pickDeliveryAddress(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/select-address-map');

    if (!mounted) return;
    if (result is Map) {
      setState(() => _deliveryAddress = Map<String, dynamic>.from(result));
    }
  }

  Widget _deliveryDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _landmarkCtrl,
              decoration: const InputDecoration(
                labelText: "Landmark / nearby place",
                hintText: "e.g. Beside Lamed Pharmacy",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _stopPointCtrl,
              decoration: const InputDecoration(
                labelText: "Where should rider stop?",
                hintText: "e.g. At the main gate",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _deliveryInstructionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Extra delivery instruction",
                hintText: "e.g. Ask of the receptionist / call when close",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _customerName,
              decoration: const InputDecoration(
                labelText: "Your name (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _customerPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Your phone number (required)",
                hintText: "e.g. 08012345678",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Rider will use this number to call you on arrival.",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsCard({
    required List<Map<String, dynamic>> items,
    required int itemsTotal,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            if (items.isEmpty)
              const Text(
                "No items were passed to checkout.",
                style: TextStyle(color: Colors.black54),
              ),
            if (items.isNotEmpty)
              ...items.map((it) {
                final name = (it['name'] ?? it['title'] ?? 'Item').toString();
                final qty = _asInt(it['qty']) ?? _asInt(it['quantity']) ?? 1;
                final price = _asInt(it['price']) ?? 0;
                final line = price * qty;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$name  ×$qty",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        "₦$line",
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              }).toList(),
            const Divider(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Subtotal",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  "₦$itemsTotal",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _riderContactCard({required String name, required String phone}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.delivery_dining)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => callPhone(phone),
                    icon: const Icon(Icons.call),
                    label: const Text("Call"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openWhatsApp(
                      phone,
                      message:
                          "Hi, please I'm the customer. I'm waiting at my address.",
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard() {
    return Card(
      child: Column(
        children: [
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.cash,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            title: const Text(
              "Cash",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text("Pay on delivery."),
            secondary: const Icon(Icons.payments_outlined),
          ),
          const Divider(height: 0),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.card,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            title: const Text(
              "Card",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text("Pay securely with Paystack."),
            secondary: const Icon(Icons.credit_card),
          ),
          const Divider(height: 0),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.transfer,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
            title: const Text(
              "Transfer",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text("Get a RuralGo account number to transfer."),
            secondary: const Icon(Icons.account_balance_outlined),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required int itemsTotal,
    required int deliveryFee,
    required int serviceFee,
    required int tip,
    required int total,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _lineAmount("Items subtotal", itemsTotal),
            _lineAmount("Delivery fee", deliveryFee),
            _lineAmount("Service fee", serviceFee),
            _lineAmount("Tip", tip),
            const Divider(height: 22),
            _lineAmount("Total", total, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _lineAmount(String label, int value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            "₦$value",
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineText(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add a note",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    "e.g. Call me on arrival / Gate is the second left...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTipSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 10,
            children: [
              const Text(
                "Courier tip",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  _tipChip(context, "₦0", 0),
                  _tipChip(context, "₦200", 200),
                  _tipChip(context, "₦500", 500),
                  _tipChip(context, "₦1000", 1000),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipChip(BuildContext context, String label, int value) {
    final selected = tip == value;
    return ChoiceChip(
      selected: selected,
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onSelected: (_) {
        setState(() => tip = value);
        Navigator.pop(context);
      },
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (response.body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data["message"] ?? "Server error: ${response.statusCode}");
      }

      return data;
    } on TimeoutException {
      throw Exception("Server timeout. Ensure node server.js is running.");
    } on FormatException {
      throw Exception("Invalid response from server");
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<void> _handlePay(
  BuildContext context, {
  required String orderId,
  required String orderType,
  required int total,
  required int itemsTotal,
  required List<Map<String, dynamic>> items,
  required String vendorName,
}) async {
    if (_deliveryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please select delivery address.")),
      );
      return;
    }

    if (_customerPhone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please enter your phone number.")),
      );
      return;
    }

   final checkoutData = <String, dynamic>{
  "orderId": orderId,
  "orderType": orderType,

  // better rider-facing fields
  "title": vendorName.isNotEmpty
    ? vendorName
    : "Restaurant / Store Order",

"itemSummary": items.isNotEmpty
    ? items.map((e) {
        final name = (e["name"] ?? e["title"] ?? "Item").toString();
        final qty = (e["qty"] ?? e["quantity"] ?? 1).toString();
        return "$name x$qty";
      }).join(", ")
    : "Order item",

"pickupText": vendorName.isNotEmpty ? vendorName : "Vendor pickup",

  "dropoffText": (_deliveryAddress?['fullAddress'] ??
          _deliveryAddress?['displayAddress'] ??
          _deliveryAddress?['subtitle'] ??
          "")
      .toString(),

  "customerPhone": _customerPhone.text.trim(),
  "customerName": _customerName.text.trim(),

  "landmark": _landmarkCtrl.text.trim(),
  "stopPoint": _stopPointCtrl.text.trim(),
  "deliveryInstruction": _deliveryInstructionCtrl.text.trim(),

  "deliveryAddress": _deliveryAddress,
  "customer": {
    "name": _customerName.text.trim(),
    "phone": _customerPhone.text.trim(),
  },
  "deliveryDetails": {
    "landmark": _landmarkCtrl.text.trim(),
    "stopPoint": _stopPointCtrl.text.trim(),
    "instruction": _deliveryInstructionCtrl.text.trim(),
  },

  "items": items,
  "itemsTotal": itemsTotal,
  "specialHandling": specialHandling,
  "note": _note.text.trim(),
  "tip": tip,
  "paymentMethod": _paymentMethod.name,
  "paymentStatus":
      _paymentMethod == PaymentMethod.cash ? "unpaid" : "pending",
  "total": total,
  "status": "pending",
  "createdAt": FieldValue.serverTimestamp(),
  "updatedAt": FieldValue.serverTimestamp(),
};

    if (_paymentMethod == PaymentMethod.cash) {
      _showSimpleSheet(
        context,
        title: "Cash Payment",
        subtitle: "You will pay the rider on delivery.",
        total: total,
        primaryText: "Place order",
        onPrimary: () async {
          Navigator.pop(context);
          await _confirmOrder(context, orderId, checkoutData);
        },
      );
      return;
    }
   final phone = _customerPhone.text.trim().replaceAll(' ', '');
    final email = "$phone@ruralgo.com";

    if (_paymentMethod == PaymentMethod.transfer) {
      try {
        final fullName = _customerName.text.trim();
        final parts =
            fullName.split(' ').where((e) => e.trim().isNotEmpty).toList();

        final firstName = parts.isNotEmpty ? parts.first : 'Rural';
        final lastName =
            parts.length > 1 ? parts.sublist(1).join(' ') : 'Customer';

        final data = await _postJson(
          _paystackTransferUrl,
          {
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "phone": phone,
          },
        );

        if (data["status"] != true || data["data"] == null) {
          throw Exception(data["message"] ?? "Transfer account failed");
        }

        final acc = data["data"] as Map<String, dynamic>;
        final bank = (acc["bank"] ?? {}) as Map<String, dynamic>;

        if (!mounted) return;

        _showTransferSheet(
          context,
          total: total,
          bankName: (bank["name"] ?? "Bank").toString(),
          accountNumber: (acc["account_number"] ?? "").toString(),
          accountName: (acc["account_name"] ?? "RuralGo").toString(),
          onConfirm: () async {
            Navigator.pop(context);
            await _confirmOrder(context, orderId, checkoutData);
          },
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Transfer error: $e")),
        );
      }

      return;
    }

    try {
      final data = await _postJson(
        _paystackInitUrl,
        {
          "email": email,
          "amount": total * 100,
          "reference": orderId,
        },
      );

      if (data["status"] != true || data["data"] == null) {
        throw Exception(data["message"] ?? "Payment initialization failed");
      }

      final accessCode = data["data"]["access_code"];
      if (accessCode == null || accessCode.toString().isEmpty) {
        throw Exception("No access code returned from server");
      }

      const paystack = PaystackPayment();

      await paystack.checkout(
        context: context,
        accessCode: accessCode.toString(),
        onSuccess: (result) async {
          checkoutData["paymentStatus"] = "paid";
          await _confirmOrder(context, orderId, checkoutData);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Payment successful")),
          );
        },
        onCancel: (response) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Payment cancelled")),
          );
        },
        onError: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Payment error: $error")),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Payment error: $e")),
      );
    }
  }

  Future<void> _confirmOrder(
    BuildContext context,
    String orderId,
    Map<String, dynamic> checkoutData,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection("Orders")
          .doc(orderId)
          .set(checkoutData, SetOptions(merge: true));

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to place order: $e")),
        );
      }
    }
  }

  void _showSimpleSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int total,
    required String primaryText,
    required Future<void> Function() onPrimary,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Amount",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    "₦$total",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => onPrimary(),
                  child: Text(
                    primaryText,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransferSheet(
    BuildContext context, {
    required int total,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required Future<void> Function() onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Bank Transfer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 12),
              _lineText("Bank", bankName),
              _lineText("Account No", accountNumber, bold: true),
              _lineText("Account Name", accountName),
              _lineText("Amount", "₦$total", bold: true),
              const SizedBox(height: 12),
              const Text(
                "Transfer the exact amount to this RuralGo account, then tap the button below.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => onConfirm(),
                  child: const Text(
                    "I’ve sent the money",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      );

  Widget _tileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _switchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  String _payButtonText(int total) {
    switch (_paymentMethod) {
      case PaymentMethod.cash:
        return "Place order (Cash) • ₦$total";
      case PaymentMethod.card:
        return "Pay now • ₦$total";
      case PaymentMethod.transfer:
        return "Get account details • ₦$total";
    }
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  List<Map<String, dynamic>> _toItemList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  int _calcItemsTotal(List<Map<String, dynamic>> items) {
    int sum = 0;
    for (final it in items) {
      final qty = _asInt(it['qty']) ?? _asInt(it['quantity']) ?? 1;
      final price = _asInt(it['price']) ?? 0;
      sum += price * qty;
    }
    return sum;
  }
}
