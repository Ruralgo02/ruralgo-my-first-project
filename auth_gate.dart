import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'splash_page.dart';
import 'welcome_page.dart';
import 'verify_email_page.dart';
import '../app_shell.dart';

class AuthGate extends StatefulWidget {
  /// ✅ Root entry point
  static const routeName = '/';
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  final _appLinks = AppLinks();

  StreamSubscription<Uri>? _sub;

  bool _doneSplash = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ✅ Splash timeout (shorter + safer)
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _doneSplash = true);
    });

    _startLinkListener();
  }

  // ===================== MAGIC LINK HANDLING (KEPT) =====================

  Future<void> _startLinkListener() async {
    try {
      // App opened from CLOSED state via link
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } catch (_) {}

    // App opened from BACKGROUND via link
    _sub = _appLinks.uriLinkStream.listen((uri) async {
      await _handleIncomingUri(uri);
    });
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final ok = await _authService.handleEmailVerificationLink(uri);

    if (!mounted) return;

    if (ok) {
      // ✅ Ensure Firebase reloads user after verification
      await FirebaseAuth.instance.currentUser?.reload();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppShell.routeName,
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    // ✅ Splash screen
    if (!_doneSplash) return const SplashPage();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;

        // ✅ Not logged in → Welcome
        if (user == null) {
          return const WelcomePage();
        }

        // ✅ Reload user once to ensure emailVerified is fresh
        user.reload();

        // ✅ Only enforce verification for email/password users
        final providerIds =
            user.providerData.map((e) => e.providerId).toList();
        final isPasswordUser = providerIds.contains('password');

        if (isPasswordUser && !user.emailVerified) {
          return const VerifyEmailPage();
        }

        // ✅ Logged in & verified → AppShell
        return const AppShell();
      },
    );
  }
}