import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../app_shell.dart';
import 'welcome_page.dart';

class VerifyEmailPage extends StatefulWidget {
  static const routeName = '/verify-email';
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _authService = AuthService();
  bool _loading = false;
  String? _info;

  Future<void> _checkVerified() async {
    setState(() {
      _loading = true;
      _info = null;
    });

    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;

      if (!mounted) return;

      if (user != null && user.emailVerified) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppShell.routeName,
          (_) => false,
        );
        return;
      }

      setState(() {
        _info = "Not verified yet. Please check your inbox/spam, then tap I've verified.";
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _info = "Could not confirm verification. Try again.\n$e";
        _loading = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() {
      _info = null;
      _loading = true;
    });

    try {
      await _authService.resendVerificationEmail();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _info = "Verification email sent again. Please check inbox/spam.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _info = "Could not resend email.\n$e";
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      WelcomePage.routeName,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _logout,
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "We sent a verification email to:",
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (_info != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_info!),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _checkVerified,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("I've verified"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: _loading ? null : _resend,
                child: const Text("Resend email"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}