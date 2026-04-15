import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportPage extends StatelessWidget {
  static const String routeName = '/contact-support';
  const ContactSupportPage({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  // ✅ EDIT THESE TO YOUR REAL SUPPORT DETAILS
  static const String _supportPhone = '+2348000000000';
  static const String _supportWhatsApp = '2348000000000'; // no "+"
  static const String _supportEmail = 'support@ruralgo.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'How can we help you?',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose any option below. For faster support, include screenshots and the phone/email you used to sign in.',
                    style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          const _SectionTitle('Quick actions'),
          _Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat on WhatsApp',
                  subtitle: 'Fastest response',
                  onTap: _openWhatsApp,
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.call_outlined,
                  title: 'Call support',
                  subtitle: 'Speak with our team',
                  onTap: _call,
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.email_outlined,
                  title: 'Email support',
                  subtitle: 'Send details + screenshots',
                  onTap: _email,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const _SectionTitle('Report an issue'),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Before you send a message, check these:',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _bullet('Your phone number/email used to login'),
                  _bullet('What you were trying to do (e.g., “Map not loading”)'),
                  _bullet('Any error message you saw'),
                  _bullet('Screenshots (very important)'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _email(
                        subject: 'RuralGo Issue Report',
                        body: _defaultIssueTemplate(),
                      ),
                      icon: const Icon(Icons.bug_report_outlined),
                      label: const Text(
                        'Send issue report',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, color: _brandGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Security tip: Never share your password or OTP code with anyone.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helpers ----------

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle, size: 18, color: _brandGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  static String _defaultIssueTemplate() {
    return '''
Hello RuralGo Support,

I need help with:

1) Issue:
- (Describe what happened)

2) Steps to reproduce:
- Step 1...
- Step 2...

3) Device:
- Android model:
- Android version:

4) Account:
- Phone/Email used to login:

5) Screenshots:
- Attached

Thank you.
''';
  }

  Future<void> _openWhatsApp() async {
    const message = 'Hello RuralGo Support, I need help with...';
    final uri = Uri.parse(
      'https://wa.me/$_supportWhatsApp?text=${Uri.encodeComponent(message)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:$_supportPhone');
    await launchUrl(uri);
  }

  Future<void> _email({
    String subject = 'RuralGo Support Request',
    String body = 'Hello Support, I need help with...',
  }) async {
    final uri = Uri.parse(
      'mailto:$_supportEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    await launchUrl(uri);
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x3300A082)),
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A082)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        try {
          await onTap();
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open this option')),
          );
        }
      },
    );
  }
}