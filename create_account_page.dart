import 'package:flutter/material.dart';

class CreateAccountPage extends StatelessWidget {
  static const routeName = '/create-account';
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create account")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.person_add_alt_1, size: 60, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              "Choose how you want to continue",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 22),

            // ✅ EMAIL (MAGIC LINK – GLOVO STYLE)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text("Continue with Email"),
                onPressed: () {
                  Navigator.pushNamed(context, '/email-start');
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ PHONE (OTP)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: const Text("Continue with Phone"),
                onPressed: () {
                  Navigator.pushNamed(context, '/phone-start');
                },
              ),
            ),

            const Spacer(),

            Text(
              "Email uses a secure sign-in link.\nPhone uses OTP verification.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}