import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/ensure_display_name.dart';
import '../app_shell.dart';

class PhoneOtpPage extends StatefulWidget {
  static const routeName = '/phone-otp';
  const PhoneOtpPage({super.key});

  @override
  State<PhoneOtpPage> createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends State<PhoneOtpPage> {
  final _codeController = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  String? _phone;

  bool _loading = false;
  String? _message;

  Timer? _timer;
  int _secondsLeft = 60;
  bool _canResend = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _phone = args["phone"];
      _verificationId = args["verificationId"];
      _resendToken = args["resendToken"];
    }

    if (_verificationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;

    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() => _message = "Enter valid 6-digit code");
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (result.user != null) {
        await ensureDisplayName(result.user!);
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppShell.routeName,
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? "Invalid code");
    } catch (_) {
      setState(() => _message = "Verification failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_phone == null) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phone!,
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (credential) async {
        final result =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (result.user != null) {
          await ensureDisplayName(result.user!);
        }

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppShell.routeName,
          (_) => false,
        );
      },

      verificationFailed: (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _message = e.message ?? "Verification failed";
        });
      },

      codeSent: (verificationId, resendToken) {
        if (!mounted) return;

        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _loading = false;
          _message = "Code sent again";
        });

        _startTimer();
      },

      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _verificationId != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Verification Code")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline, size: 70),
            const SizedBox(height: 20),

            Text(
              _phone != null
                  ? "Enter the code sent to\n$_phone"
                  : "Enter verification code",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "6-digit code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains("sent")
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (!_loading && ready) ? _verifyCode : null,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Verify"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: (_canResend && !_loading) ? _resendCode : null,
                child: _canResend
                    ? const Text("Resend Code")
                    : Text(
                        "Resend in 00:${_secondsLeft.toString().padLeft(2, '0')}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}