import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_shell.dart';
import 'email_signup_page.dart';
import 'verify_email_page.dart';

class UserLoginPage extends StatefulWidget {
  static const routeName = '/user-login';
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Enter email and password");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception("Login failed");

      // ✅ Always reload so emailVerified is fresh
      await user.reload();
      final fresh = FirebaseAuth.instance.currentUser;

      if (fresh == null) throw Exception("Login session lost");

      // ✅ If email not verified, send them to VerifyEmailPage
      if (!fresh.emailVerified) {
        // Optional: resend verification (can be rate-limited by Firebase)
        try {
          await fresh.sendEmailVerification();
        } catch (_) {
          // ignore resend errors, still go to verify page
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, VerifyEmailPage.routeName);
        return;
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppShell.routeName,
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Login failed");
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Enter your email first");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _error = "Password reset link sent to email");
    } catch (e) {
      setState(() => _error = "Could not send reset email: $e");
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign in")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _forgotPassword,
                child: const Text("Forgot password?"),
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: _error!.contains("sent") ? Colors.green : Colors.red,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Sign in"),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, EmailSignupPage.routeName);
              },
              child: const Text("No account? Create one"),
            ),
          ],
        ),
      ),
    );
  }
}