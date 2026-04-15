import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'phone_otp_page.dart';

class PhoneStartPage extends StatefulWidget {
  static const routeName = '/phone-start';
  const PhoneStartPage({super.key});

  @override
  State<PhoneStartPage> createState() => _PhoneStartPageState();
}

class _PhoneStartPageState extends State<PhoneStartPage> {
  final _phone = TextEditingController(text: "+234");
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool _isValidPhone(String v) {
    final x = v.trim();
    // basic E.164 check: starts with + and has at least 8 digits total
    return x.startsWith('+') && x.length >= 8;
  }

  Future<void> _sendCode() async {
    final raw = _phone.text.trim();

    if (!_isValidPhone(raw)) {
      setState(() => _error = "Enter phone e.g. +2348012345678");
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      int? resendToken;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: raw,
        timeout: const Duration(seconds: 60),

        // ✅ If Google Play Services can instantly verify, it will complete here
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);

            if (!mounted) return;
            // If auto-verified, go straight to your app shell
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/shell', // or AppShell.routeName if you prefer importing it
              (_) => false,
            );
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _error = "Auto verification failed. Please enter the code manually.";
            });
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error = e.message ?? "Verification failed. Try again.";
          });
        },

        codeSent: (String verificationId, int? token) {
          resendToken = token;

          if (!mounted) return;
          setState(() => _loading = false);

          // ✅ Navigate to OTP page WITH verificationId + phone + resendToken
          Navigator.pushNamed(
            context,
            PhoneOtpPage.routeName,
            arguments: {
              "phone": raw,
              "verificationId": verificationId,
              "resendToken": resendToken,
            },
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // No UI action needed — OTP page can still verify using the saved ID
        },

        // ✅ For resend optimisation
        forceResendingToken: resendToken,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Could not send code: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Continue with Phone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Enter your phone number to receive a code."),
            const SizedBox(height: 14),

            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone (+countrycode...)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendCode,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}