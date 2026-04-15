import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'phone_otp_page.dart';

class VerifyPhonePage extends StatefulWidget {
  static const routeName = '/verify-phone';
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  PhoneNumber _number = PhoneNumber(isoCode: 'NG');
  String? _e164Phone;

  bool _loading = false;
  String? _error;

  int? _resendToken;

  bool _looksLikeE164(String value) {
    // E.164: +<countrycode><number>, basic checks
    if (!value.startsWith('+')) return false;
    if (value.length < 8) return false;
    // Must be digits after "+"
    return RegExp(r'^\+\d{7,15}$').hasMatch(value);
  }

  Future<void> _sendCode({bool isResend = false}) async {
    final phone = _e164Phone?.trim();

    if (phone == null || !_looksLikeE164(phone)) {
      setState(() => _error = "Enter a valid phone number (e.g. +2348012345678)");
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        // If Android can auto-verify (rare), this triggers.
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/shell', (_) => false);
          } catch (e, st) {
            log("AUTO VERIFY SIGN-IN FAILED", error: e, stackTrace: st);
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          log("PHONE AUTH FAILED: ${e.code} - ${e.message}");
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error = "${e.code}: ${e.message ?? 'Verification failed'}";
          });
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _resendToken = resendToken;
          });

          Navigator.pushNamed(
            context,
            PhoneOtpPage.routeName,
            arguments: {
              "phone": phone,
              "verificationId": verificationId,
              "resendToken": resendToken,
            },
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Not an error — just means auto-retrieval timed out.
          log("AUTO RETRIEVAL TIMEOUT. verificationId=$verificationId");
        },

        // Only set forceResendingToken when resending
        forceResendingToken: isResend ? _resendToken : null,
      );
    } catch (e, st) {
      log("verifyPhoneNumber THROW", error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Something went wrong. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone number")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Select your country and enter your phone number."),
            const SizedBox(height: 14),

            InternationalPhoneNumberInput(
              initialValue: _number,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
              ),
              inputDecoration: const InputDecoration(
                labelText: "Phone number",
                hintText: "e.g. 08012345678",
                border: OutlineInputBorder(),
              ),
              onInputChanged: (PhoneNumber number) {
                _number = number;
                _e164Phone = number.phoneNumber; // usually already E.164 like +234...
              },
              autoValidateMode: AutovalidateMode.disabled,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
            ),

            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _sendCode(),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send code"),
              ),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : () => _sendCode(isResend: true),
              child: const Text("Resend code"),
            ),
          ],
        ),
      ),
    );
  }
}