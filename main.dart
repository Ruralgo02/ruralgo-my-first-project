// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ ADDED (ONLY)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADDED (ONLY)
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // ✅ App Check

import 'firebase_options.dart';
import 'providers/cart_provider.dart';

import 'app_shell.dart';

// AuthService (email link handler) - safe even if paused
import 'services/auth_service.dart';

// Auth screens
import 'screens/auth_gate.dart';
import 'screens/auth_choice_page.dart';
import 'screens/email_signup_page.dart';
import 'screens/user_login_page.dart';
import 'screens/verify_email_page.dart';
import 'screens/verify_phone_page.dart';
import 'screens/phone_otp_page.dart';

// Splash + Welcome
import 'screens/splash_page.dart';
import 'screens/welcome_page.dart';

// Core app screens
import 'screens/cart_page.dart';
import 'screens/products_page.dart';
import 'screens/store_page.dart';
import 'screens/parcels_page.dart';
import 'screens/parcels_map_page.dart';

// Parcels booking + checkout + map picker
import 'screens/parcels_booking_page.dart';
import 'screens/checkout_page.dart';
import 'screens/select_address_map_page.dart';

// Map Test
import 'screens/map_test_page.dart';

// Profile + Help + Wallet + Addresses
import 'screens/profile_page.dart';
import 'screens/help_center_page.dart';
import 'screens/wallet_page.dart';
import 'screens/addresses_page.dart';
import 'screens/saved_addresses_page.dart';

// Optional pages used by Profile (must exist + must have routeName)
import 'screens/personal_details_page.dart';
import 'screens/orders_page.dart';
import 'screens/contact_support_page.dart';
import 'screens/tracking_page.dart';

// Vendor
import 'screens/vendor_login_page.dart';
import 'screens/vendor_dashboard_page.dart';
import 'screens/vendor_store_profile_page.dart';
import 'screens/vendor_products_page.dart';
import 'screens/vendor_orders_page.dart';
import 'screens/vendor_wallet_page.dart';

// Rider
import 'screens/rider_login_page.dart';
import 'screens/rider_dashboard_page.dart';
import 'screens/rider_jobs_page.dart';
import 'screens/rider_wallet_page.dart';   // ✅ NEW
import 'screens/rider_profile_page.dart';  // ✅ NEW

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: kReleaseMode
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug,
  );

  runApp(const RuralGoApp());
}

class RuralGoApp extends StatelessWidget {
  const RuralGoApp({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _softBg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _softBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandGreen,
        primary: _brandGreen,
        background: _softBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _brandGreen,
          side: const BorderSide(color: _brandGreen),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RuralGo',
        theme: theme,
        builder: (context, child) {
          return _EmailLinkHandler(child: child ?? const SizedBox.shrink());
        },
        initialRoute: AuthGate.routeName,
        routes: {
          // Splash + Welcome
          SplashPage.routeName: (_) => SplashPage(),
          WelcomePage.routeName: (_) => WelcomePage(),

          // Auth
          AuthGate.routeName: (_) => AuthGate(),
          AuthChoicePage.routeName: (_) => AuthChoicePage(),
          EmailSignupPage.routeName: (_) => EmailSignupPage(),
          UserLoginPage.routeName: (_) => UserLoginPage(),
          VerifyEmailPage.routeName: (_) => VerifyEmailPage(),
          VerifyPhonePage.routeName: (_) => VerifyPhonePage(),

          // App shell
          AppShell.routeName: (_) => AppShell(),
          '/app-shell': (_) => AppShell(),

          // Core app pages
          CartPage.routeName: (_) => CartPage(),
          ParcelsPage.routeName: (_) => ParcelsPage(),
          ParcelsMapPage.routeName: (_) => ParcelsMapPage(),

          // Checkout + map picker
          CheckoutPage.routeName: (_) => CheckoutPage(),
          SelectAddressMapPage.routeName: (_) => SelectAddressMapPage(),

          // Map test
          MapTestPage.routeName: (_) => MapTestPage(),

          // Profile + Help + Wallet + Addresses
          ProfilePage.routeName: (_) => ProfilePage(),
          HelpCenterPage.routeName: (_) => HelpCenterPage(),
          WalletPage.routeName: (_) => WalletPage(),
          AddressesPage.routeName: (_) => AddressesPage(),
          SavedAddressesPage.routeName: (_) => const SavedAddressesPage(),

          // Optional pages used by Profile
          PersonalDetailsPage.routeName: (_) => PersonalDetailsPage(),
          OrdersPage.routeName: (_) => OrdersPage(),
          ContactSupportPage.routeName: (_) => ContactSupportPage(),

          // Vendor
          VendorLoginPage.routeName: (_) => VendorLoginPage(),
          VendorDashboardPage.routeName: (_) => VendorDashboardPage(),
          VendorStoreProfilePage.routeName: (_) => VendorStoreProfilePage(),
          VendorProductsPage.routeName: (_) => VendorProductsPage(),
          VendorOrdersPage.routeName: (_) => VendorOrdersPage(),
          VendorWalletPage.routeName: (_) => VendorWalletPage(),

          // Rider
          RiderLoginPage.routeName: (_) => RiderLoginPage(),
          RiderDashboardPage.routeName: (_) => RiderDashboardPage(),
          RiderJobsPage.routeName: (_) => RiderJobsPage(),
          RiderWalletPage.routeName: (_) => const RiderWalletPage(),     // ✅ NEW
          RiderProfilePage.routeName: (_) => const RiderProfilePage(),   // ✅ NEW
        },

        onGenerateRoute: (settings) {
          if (settings.name == PhoneOtpPage.routeName) {
            return MaterialPageRoute(
              builder: (_) => PhoneOtpPage(),
              settings: settings,
            );
          }

          if (settings.name == ParcelsBookingPage.routeName) {
            final args = settings.arguments;

            final String serviceName = args is String
                ? args
                : (args is Map && args['serviceName'] != null)
                    ? args['serviceName'] as String
                    : 'Parcels';

            return MaterialPageRoute(
              builder: (_) => ParcelsBookingPage(serviceName: serviceName),
              settings: settings,
            );
          }

          if (settings.name == ProductsPage.routeName) {
            final args = settings.arguments;

            final String category = args is String
                ? args
                : (args is Map && args['category'] != null)
                    ? args['category'] as String
                    : 'Restaurants';

            final String? searchQuery =
                args is Map && args['searchQuery'] != null
                    ? args['searchQuery'].toString()
                    : null;

            return MaterialPageRoute(
              builder: (_) => ProductsPage(
                category: category,
                searchQuery: searchQuery,
              ),
              settings: settings,
            );
          }

          if (settings.name == StorePage.routeName) {
            final args = settings.arguments;

            final String storeName = args is String
                ? args
                : (args is Map && args['storeName'] != null)
                    ? args['storeName'] as String
                    : 'Store';

            return MaterialPageRoute(
              builder: (_) => StorePage(storeName: storeName),
              settings: settings,
            );
          }

          // ✅ REAL tracking route
          if (settings.name == "/tracking") {
            final args = settings.arguments;

            final String orderId = args is Map && args['orderId'] != null
                ? args['orderId'].toString()
                : '';

            return MaterialPageRoute(
              builder: (_) => TrackingPage(orderId: orderId),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Route error')),
              body: Center(child: Text('Page not found:\n${settings.name}')),
            ),
            settings: settings,
          );
        },
      ),
    );
  }
}

class _EmailLinkHandler extends StatefulWidget {
  final Widget child;
  const _EmailLinkHandler({required this.child});

  @override
  State<_EmailLinkHandler> createState() => _EmailLinkHandlerState();
}

class _EmailLinkHandlerState extends State<_EmailLinkHandler> {
  StreamSubscription<Uri>? _sub;
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();

    final appLinks = AppLinks();
    _sub = appLinks.uriLinkStream.listen((uri) async {
      try {
        final ok = await _auth.handleEmailVerificationLink(uri);
        if (!mounted) return;

        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Email verified successfully')),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppShell.routeName,
            (_) => false,
          );
        }
      } catch (_) {
        // keep silent
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}