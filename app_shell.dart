import 'package:flutter/material.dart';

// Screens
import 'screens/home_page.dart';
import 'screens/search_page.dart';
import 'screens/orders_page.dart';
import 'screens/profile_page.dart';

class AppShell extends StatefulWidget {
  /// ✅ Single source of truth for shell route
  static const routeName = '/shell';

  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // ✅ RuralGo brand colors (aligned with HomePage)
  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _brandBg = Color(0xFFE9FBF6);

  // ✅ Bottom nav pages (order matters)
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _brandBg,

      // ✅ Active page
      body: _pages[_index],

      // ✅ Bottom Navigation (Glovo-style pill indicator)
      bottomNavigationBar: NavigationBar(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.white,

        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i != _index) {
            setState(() => _index = i);
          }
        },

        // Soft green pill highlight
        indicatorColor: _brandGreen.withOpacity(0.18),

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}