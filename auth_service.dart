import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Single GoogleSignIn instance
  final GoogleSignIn _google = GoogleSignIn(scopes: ['email']);

  // Current user
  User? get currentUser => _auth.currentUser;

  Future<void> reloadUser() async {
    final u = _auth.currentUser;
    if (u == null) return;
    await u.reload();
  }

  // =========================
  // ✅ EMAIL VERIFICATION SETTINGS (RETURN TO APP)
  // =========================
  ActionCodeSettings _emailActionSettings() {
    // IMPORTANT:
    // url = continue URL (where user is redirected after verification)
    // NOT /__/auth/action
    //
    // Keep this as your Firebase Hosting root until your custom domain is ready.
    const continueUrl = 'https://ruralgo-204eb.web.app/';

    return ActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,

      // Android
      androidPackageName: 'com.oge.ruralgo',
      androidInstallApp: true,
      androidMinimumVersion: '21',

      // iOS (safe to keep even if you’re not using iOS yet)
      // iosBundleId: 'com.oge.ruralgo',
    );
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user is logged in.");
    if (user.emailVerified) return;

    await user.sendEmailVerification(_emailActionSettings());
  }

  // =========================
  // EMAIL SIGN UP
  // =========================
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = cred.user;
    if (user == null) throw Exception("Signup failed. Please try again.");

    // ✅ Force displayName
    final safeName =
        cleanName.isNotEmpty ? cleanName : _nameFromEmail(cleanEmail);

    if ((user.displayName ?? '').trim() != safeName) {
      await user.updateDisplayName(safeName);
      await user.reload();
    }

    // ✅ Save / update Firestore without overwriting createdAt
    final docRef = _db.collection('users').doc(user.uid);
    final snap = await docRef.get();

    final payload = <String, dynamic>{
      "uid": user.uid,
      "name": safeName,
      "email": cleanEmail,
      "phone": user.phoneNumber,
      "role": "user",
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      payload["createdAt"] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));

    // ✅ Send verification email (in-app handling)
    if (!user.emailVerified) {
      await user.sendEmailVerification(_emailActionSettings());
    }

    return cred;
  }

  // =========================
  // EMAIL LOGIN
  // =========================
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // =========================
  // GOOGLE SIGN IN
  // =========================
  Future<UserCredential> signInWithGoogle() async {
    // ✅ force account chooser
    await _google.signOut();

    final GoogleSignInAccount? googleUser = await _google.signIn();
    if (googleUser == null) throw Exception("Google sign-in cancelled");

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);

    final user = cred.user;
    if (user == null) throw Exception("Google sign-in failed");

    // ✅ Better name fallback
    final safeName =
        (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null ? _nameFromEmail(user.email!) : "User");

    if ((user.displayName ?? '').trim().isEmpty || user.displayName != safeName) {
      await user.updateDisplayName(safeName);
      await user.reload();
    }

    // ✅ Firestore upsert
    final docRef = _db.collection('users').doc(user.uid);
    final snap = await docRef.get();

    final payload = <String, dynamic>{
      "uid": user.uid,
      "name": safeName,
      "email": user.email,
      "phone": user.phoneNumber,
      "role": "user",
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      payload["createdAt"] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));

    return cred;
  }

  // =========================
  // ✅ EMAIL VERIFICATION LINK HANDLER
  // Supports links like:
  //  - https://ruralgo-204eb.firebaseapp.com/__/auth/action?mode=verifyEmail&oobCode=...
  //  - https://ruralgo-204eb.web.app/__/auth/action?mode=verifyEmail&oobCode=...
  // =========================
  Future<bool> handleEmailVerificationLink(Uri uri) async {
    try {
      final mode = uri.queryParameters['mode'];
      final code = uri.queryParameters['oobCode'];

      if (mode != 'verifyEmail' || code == null || code.isEmpty) return false;

      await _auth.applyActionCode(code);

      // Reload so emailVerified updates
      await reloadUser();

      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {
      // ignore
    }
  }

  static String _nameFromEmail(String email) {
    final left = email.split('@').first.trim();
    if (left.isEmpty) return "User";
    final pretty = left.replaceAll(RegExp(r'[_\.\-]+'), ' ');
    return pretty[0].toUpperCase() + pretty.substring(1);
  }
}