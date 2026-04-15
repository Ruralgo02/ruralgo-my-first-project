import 'package:firebase_auth/firebase_auth.dart';

Future<void> ensureDisplayName(User user) async {
  if ((user.displayName ?? '').isNotEmpty) return;

  String name;

  if (user.email != null && user.email!.contains('@')) {
    name = user.email!.split('@').first;
  } else if (user.phoneNumber != null) {
    name = user.phoneNumber!;
  } else {
    name = 'RuralGo';
  }

  await user.updateDisplayName(name);
  await user.reload();
}