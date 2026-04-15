import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class EmailLinkHandler {
  static Future<void> init() async {
    // If app was closed and opened by link
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      await _handleUri(initialLink.link);
    }

    // If app was in background and opened by link
    FirebaseDynamicLinks.instance.onLink.listen((event) async {
      await _handleUri(event.link);
    });
  }

  static Future<void> _handleUri(Uri link) async {
    final mode = link.queryParameters['mode'];
    final oobCode = link.queryParameters['oobCode'];

    if (mode == 'verifyEmail' && oobCode != null) {
      await FirebaseAuth.instance.applyActionCode(oobCode);
      await FirebaseAuth.instance.currentUser?.reload();
    }
  }
}