import 'dart:async';
import 'package:flutter/material.dart';

/// Shows the "Payment pending" bank transfer bottom sheet.
/// Returns:
/// - true  => user clicked "I've sent the money"
/// - false => user cancelled/closed
///
/// Usage:
/// final paid = await showPaymentPendingSheet(
///   context,
///   total: 1000,
///   accountName: "RURALGO TECHNOLOGIES LTD",
///   bankName: "Paystack-Titan",
///   accountNumber: "9962459234",
///   expiresInMinutes: 15,
/// );
/// if (paid == true) { ...confirm order... }
Future<bool?> showPaymentPendingSheet(
  BuildContext context, {
  required int total,
  required String accountName,
  required String bankName,
  required String accountNumber,
  int expiresInMinutes = 15,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _PaymentPendingContent(
      total: total,
      accountName: accountName,
      bankName: bankName,
      accountNumber: accountNumber,
      expiresInMinutes: expiresInMinutes,
    ),
  );
}

class _PaymentPendingContent extends StatefulWidget {
  final int total;
  final String accountName;
  final String bankName;
  final String accountNumber;
  final int expiresInMinutes;

  const _PaymentPendingContent({
    required this.total,
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.expiresInMinutes,
  });

  @override
  State<_PaymentPendingContent> createState() => _PaymentPendingContentState();
}

class _PaymentPendingContentState extends State<_PaymentPendingContent> {
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.expiresInMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final expired = _secondsLeft == 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Payment pending",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pay with Bank Transfer",
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text("Account name: ${widget.accountName}",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text("Bank: ${widget.bankName}",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text("Account number: ${widget.accountNumber}",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text("Amount: ₦${widget.total}",
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        expired
                            ? "This account has expired."
                            : "Expires in ${_mmss(_secondsLeft)}",
                        style: TextStyle(
                          color: expired ? Colors.red : Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: expired ? null : () => Navigator.pop(context, true),
                child: const Text(
                  "I've sent the money",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}