import 'package:flutter/material.dart';
import 'rider_jobs_page.dart';
import 'rider_wallet_page.dart';
import 'rider_profile_page.dart';

class RiderDashboardPage extends StatelessWidget {
  static const routeName = '/rider-dashboard';

  const RiderDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FBF6),
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        backgroundColor: const Color(0xFF00A082),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome, Rider 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Parcel Jobs'),
                subtitle: const Text('Pick parcel delivery requests'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RiderJobsPage.routeName,
                    arguments: 'parcel',
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Store / Food / Goods Jobs'),
                subtitle: const Text('Pick supermarket, restaurant and goods orders'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RiderJobsPage.routeName,
                    arguments: 'store',
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Wallet'),
                subtitle: const Text('View cash earnings and settlements'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RiderWalletPage.routeName,
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile / Settings'),
                subtitle: const Text('Update rider details and account info'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RiderProfilePage.routeName,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}