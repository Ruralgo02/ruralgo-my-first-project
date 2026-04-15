// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'welcome_page.dart';
import 'auth_choice_page.dart';

// Pages you said you have / want to use
import 'personal_details_page.dart';
import 'addresses_page.dart';
import 'orders_page.dart';
import 'wallet_page.dart';
import 'contact_support_page.dart';
import 'help_center_page.dart';

class ProfilePage extends StatelessWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);
  static const Color _cardBorder = Color(0x3300A082);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;

    return Scaffold(
      backgroundColor: _brandBg,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _HeaderCard(user: user),

          const SizedBox(height: 14),

          if (!loggedIn) ...[
            _PrimaryActionsCard(
              onCreateOrLogin: () => Navigator.pushNamed(
                context,
                AuthChoicePage.routeName,
              ),
            ),
            const SizedBox(height: 14),
            const _QuickHelpCard(),
            const SizedBox(height: 14),
            const _InfoCard(),
          ],

          if (loggedIn) ...[
            const _SectionTitle("Account"),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  title: "Personal details",
                  subtitle: "Name, phone, email",
                  onTap: () => _safePushNamed(context, PersonalDetailsPage.routeName),
                ),
                _MenuTile(
                  icon: Icons.location_on_outlined,
                  title: "Addresses",
                  subtitle: "Home, work, delivery points",
                  onTap: () => _safePushNamed(context, AddressesPage.routeName),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const _SectionTitle("Orders & Payments"),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: "My orders",
                  subtitle: "Track your orders & history",
                  onTap: () => _safePushNamed(context, OrdersPage.routeName),
                ),
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Wallet / Payment methods",
                  subtitle: "Cash, transfer, card",
                  onTap: () => _safePushNamed(context, WalletPage.routeName),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const _SectionTitle("Support"),
            _MenuCard(
              children: [
                _MenuTile(
                  icon: Icons.help_outline,
                  title: "Help center",
                  subtitle: "FAQs, payments, delivery & troubleshooting",
                  onTap: () => _safePushNamed(context, HelpCenterPage.routeName),
                ),
                _MenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: "Contact support",
                  subtitle: "Chat / WhatsApp / Call",
                  onTap: () => _safePushNamed(context, ContactSupportPage.routeName),
                ),
              ],
            ),

            const SizedBox(height: 14),
            _DangerCard(
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  WelcomePage.routeName,
                  (_) => false,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _safePushNamed(BuildContext context, String route) {
    final nav = Navigator.of(context);

    try {
      nav.pushNamed(route);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Route not registered: $route\nAdd it inside routes:{} in main.dart",
          ),
        ),
      );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final User? user;
  const _HeaderCard({required this.user});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _cardBorder = Color(0x3300A082);

  @override
  Widget build(BuildContext context) {
    final loggedIn = user != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _brandGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: _brandGreen, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: loggedIn
                ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .snapshots(),
                    builder: (context, snap) {
                      final data = snap.data?.data();
                      final fsName = (data?['name'] as String?)?.trim();
                      final displayName = user?.displayName?.trim();

                      final name = (fsName != null && fsName.isNotEmpty)
                          ? fsName
                          : ((displayName != null && displayName.isNotEmpty)
                              ? displayName
                              : "RuralGo User");

                      final emailOrPhone = user?.email ?? user?.phoneNumber ?? "";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emailOrPhone,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      );
                    },
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome 👋",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Create an account to order and track deliveries.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionsCard extends StatelessWidget {
  final VoidCallback onCreateOrLogin;
  const _PrimaryActionsCard({required this.onCreateOrLogin});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _cardBorder = Color(0x3300A082);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: onCreateOrLogin,
          child: const Text("Create account / Sign in"),
        ),
      ),
    );
  }
}

class _QuickHelpCard extends StatelessWidget {
  const _QuickHelpCard();

  static const Color _cardBorder = Color(0x3300A082);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick help", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _line("• Continue with Email: verify via email link."),
          _line("• Continue with Phone: SMS OTP code."),
          _line("• Orders: track delivery inside Orders."),
          _line("• Payments: choose cash, transfer, or card."),
        ],
      ),
    );
  }

  Widget _line(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(color: Colors.black87)),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  static const Color _cardBorder = Color(0x3300A082);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About RuralGo", style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text("Order from restaurants, supermarkets, clothing and farm produce."),
          Text("Dispatch riders deliver to your location."),
          Text("Relocation assistant helps you move & settle easily."),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Color(0xFF00A082),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x3300A082)),
      ),
      child: Column(children: _withDividers(children)),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(const Divider(height: 1));
    }
    return out;
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A082)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _DangerCard extends StatelessWidget {
  final Future<void> Function() onLogout;
  const _DangerCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red.withOpacity(0.4)),
          ),
          onPressed: () async => onLogout(),
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
        ),
      ),
    );
  }
}