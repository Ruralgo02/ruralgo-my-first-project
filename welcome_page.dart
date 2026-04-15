import 'package:flutter/material.dart';
import 'auth_choice_page.dart';
import 'vendor_login_page.dart';
import 'rider_login_page.dart';

class WelcomePage extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _tapCount = 0;

  void _onLogoTap() {
    setState(() => _tapCount++);
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.pushNamed(context, RiderLoginPage.routeName);
    }
  }

  void _onLogoLongPress() {
    Navigator.pushNamed(context, VendorLoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A082),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Logo (tap 5x = rider, long press = vendor)
              Center(
                child: GestureDetector(
                  onTap: _onLogoTap,
                  onLongPress: _onLogoLongPress,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  "RuralGo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Reliable delivery for everyday essentials — fast, simple, and secure.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // What’s inside the app
              _feature("Restaurants"),
              _feature("Farm Produce"),
              _feature("Clothing"),
              _feature("Parcels & Relocation Assistant"),

              const SizedBox(height: 12),

              const Text(
                "Everything you need in one place — order, send, and manage deliveries with real-time updates.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              // Get Started
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00A082),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AuthChoicePage.routeName);
                  },
                  child: const Text(
                    "Get started",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}