import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'phone_otp_page.dart';

class PhoneNumberPage extends StatefulWidget {
  static const routeName = '/phone-number';
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();

  PhoneNumber _number = PhoneNumber(isoCode: 'NG');
  String? _finalE164;

  String? _error;
  bool _loading = false;
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _finalE164;

    if (phone == null || !_isValid) {
      setState(() => _error = "Enter a valid phone number.");
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),

        // ✅ If instant / auto verification happens (sometimes on Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            // Go straight to OTP page? or AppShell? You can choose.
            // Most apps go to AppShell after sign-in.
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/shell',
              (_) => false,
            );
          } catch (_) {
            // ignore auto verify failure; user can still enter SMS
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error = e.message ?? "Verification failed. Try again.";
          });
        },

        // ✅ This is the key: codeSent gives verificationId + resendToken
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _loading = false);

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
          // Nothing needed here for this page
        },
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
      appBar: AppBar(title: const Text("Continue with phone")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.phone_android, size: 60, color: Colors.green),
            const SizedBox(height: 14),
            const Text(
              "Enter your phone number and we’ll send you a verification code.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),

            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber value) {
                _number = value;
                _finalE164 = value.phoneNumber;
              },
              onInputValidated: (bool valid) {
                setState(() {
                  _isValid = valid;
                  if (valid) _error = null;
                });
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              initialValue: _number,
              textFieldController: _phoneController,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              inputDecoration: InputDecoration(
                labelText: "Phone number",
                hintText: "8012345678",
                border: const OutlineInputBorder(),
                errorText: null,
              ),
            ),

            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendCode,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
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