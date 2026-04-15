import 'package:url_launcher/url_launcher.dart';

/// Normalizes Nigerian numbers:
/// - "080..." -> "+23480..."
/// - "23480..." -> "+23480..."
/// - "+23480..." stays the same
String normalizePhone(String raw) {
  var phone = raw.trim().replaceAll(' ', '');

  if (phone.startsWith('0')) {
    phone = '+234${phone.substring(1)}';
  } else if (phone.startsWith('234')) {
    phone = '+$phone';
  }
  return phone;
}

/// Call a phone number using the device dialer.
Future<void> callPhone(String phone) async {
  final p = normalizePhone(phone);
  final uri = Uri(scheme: 'tel', path: p);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch dialer for $p';
  }
}

/// Open WhatsApp chat with a message.
/// Works with +234... format.
Future<void> openWhatsApp(
  String phone, {
  required String message,
}) async {
  final p = normalizePhone(phone);
  final encoded = Uri.encodeComponent(message);

  // Preferred universal link
  final uri = Uri.parse('https://wa.me/${p.replaceAll('+', '')}?text=$encoded');

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not open WhatsApp for $p';
  }
}