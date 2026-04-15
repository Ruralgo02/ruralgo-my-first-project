import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../services/auth_service.dart';

import 'verify_phone_page.dart';
import 'email_signup_page.dart';
import 'user_login_page.dart';

class AuthChoicePage extends StatelessWidget {
  static const routeName = '/auth-choice';
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF4),
      appBar: AppBar(
        title: const Text('Get started'),
        backgroundColor: const Color(0xFF00A082),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ✅ PHONE
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: const Text(
                  "Continue with phone",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A082),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, VerifyPhonePage.routeName);
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ EMAIL SIGN UP
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text(
                  "Continue with email",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, EmailSignupPage.routeName);
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ GOOGLE
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text(
                  "Continue with Google",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  try {
                    await auth.signInWithGoogle();
                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppShell.routeName, // ✅ no hardcode
                      (_) => false,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
            ),

            const Spacer(),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, UserLoginPage.routeName);
              },
              child: const Text("Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}