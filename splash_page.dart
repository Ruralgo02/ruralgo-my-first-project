import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_page.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _t;

  @override
  void initState() {
    super.initState();

    _t = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, WelcomePage.routeName);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // ✅ LIGHT GREEN (not dark)
      backgroundColor: Color(0xFFE6F7F1),
      body: Center(
        child: Text(
          'RuralGo',
          style: TextStyle(
            color: Color(0xFF00A082),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}