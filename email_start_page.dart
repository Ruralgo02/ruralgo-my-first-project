import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailStartPage extends StatefulWidget {
  static const routeName = '/email-start';
  const EmailStartPage({super.key});

  @override
  State<EmailStartPage> createState() => _EmailStartPageState();
}

class _EmailStartPageState extends State<EmailStartPage> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  Future<void> _sendLink() async {
    final email = _email.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = "Enter a valid email address.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _sent = false;
    });

    try {
      // IMPORTANT:
      // You must set this to your Firebase Dynamic Links domain
      // Example: https://ruralgo.page.link
      // And set a packageName matching your Android applicationId
      const dynamicLinkDomain = 'https://YOUR-DYNAMIC-LINK-DOMAIN.page.link';
      const packageName = 'com.oge.ruralgo';

      final actionCodeSettings = ActionCodeSettings(
        url: dynamicLinkDomain, // used for email link redirect base
        handleCodeInApp: true,
        androidPackageName: packageName,
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.oge.ruralgo', // change if you have iOS bundle id
      );

      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Failed to send link.");
    } catch (_) {
      setState(() => _error = "Something went wrong. Try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Continue with Email")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.email_outlined, size: 60, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              "Enter your email and we’ll send you a secure sign-in link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 18),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 14),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            if (_sent)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "✅ Link sent! Check your inbox (and spam). Tap the link to open RuralGo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green),
                ),
              ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendLink,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send sign-in link"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}