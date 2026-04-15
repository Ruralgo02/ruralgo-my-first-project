import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  static const routeName = '/help-center';
  const HelpCenterPage({super.key});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          // Search (UI only)
          _SearchBar(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming next')),
              );
            },
          ),
          const SizedBox(height: 14),

          const _SectionTitle('Quick actions'),
          _Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat on WhatsApp',
                  subtitle: 'Get fast help from support',
                  onTap: () => _openWhatsApp(context),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.call_outlined,
                  title: 'Call support',
                  subtitle: 'Talk to a representative',
                  onTap: () => _callSupport(context),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.email_outlined,
                  title: 'Email support',
                  subtitle: 'Send an issue and screenshots',
                  onTap: () => _emailSupport(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const _SectionTitle('Popular topics'),
          _TopicsGrid(
            items: [
              _Topic('Getting started', Icons.rocket_launch_outlined),
              _Topic('Account & login', Icons.person_outline),
              _Topic('Orders & delivery', Icons.local_shipping_outlined),
              _Topic('Payments & wallet', Icons.account_balance_wallet_outlined),
              _Topic('Addresses & location', Icons.location_on_outlined),
              _Topic('Safety & policies', Icons.verified_user_outlined),
            ],
            onTap: (topic) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HelpTopicPage(topicTitle: topic.title),
                ),
              );
            },
          ),

          const SizedBox(height: 14),
          const _SectionTitle('FAQs'),
          _Card(
            child: const _FaqList(),
          ),

          const SizedBox(height: 14),
          const _SectionTitle('Troubleshooting'),
          _Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS code not received',
                  subtitle: 'Fix OTP / verification issues',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpTopicPage(topicTitle: 'SMS code not received'),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.map_outlined,
                  title: 'Map not loading',
                  subtitle: 'Fix Google Maps blank / crash',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpTopicPage(topicTitle: 'Map not loading'),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.lock_outline,
                  title: 'Login problems',
                  subtitle: 'Password / email verification help',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpTopicPage(topicTitle: 'Login problems'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: _brandGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: When contacting support, include screenshots and your phone number/email used to sign in.',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  // ======= QUICK ACTIONS (edit these details) =======

  Future<void> _openWhatsApp(BuildContext context) async {
    const phone = '2348000000000'; // ✅ replace with your support number (no +)
    const message = 'Hello RuralGo Support, I need help with...';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast(context, 'Could not open WhatsApp');
    }
  }

  Future<void> _callSupport(BuildContext context) async {
    const tel = 'tel:+2348000000000'; // ✅ replace
    final uri = Uri.parse(tel);

    if (!await launchUrl(uri)) {
      _toast(context, 'Could not open dialer');
    }
  }

  Future<void> _emailSupport(BuildContext context) async {
    const email = 'support@ruralgo.app'; // ✅ replace
    const subject = 'RuralGo Support Request';
    const body = 'Describe the issue here and attach screenshots if possible.';
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');

    if (!await launchUrl(uri)) {
      _toast(context, 'Could not open email app');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class HelpTopicPage extends StatelessWidget {
  final String topicTitle;
  const HelpTopicPage({super.key, required this.topicTitle});

  static const Color _brandGreen = Color(0xFF00A082);
  static const Color _bg = Color(0xFFE9FBF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(topicTitle),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    _contentFor(topicTitle),
                    style: const TextStyle(height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _contentFor(String title) {
    switch (title) {
      case 'SMS code not received':
        return '• Confirm your phone number is correct\n'
            '• Check network signal and SMS inbox\n'
            '• Wait 30–60 seconds and tap Resend\n'
            '• Restart the app and try again\n'
            '• If still failing, contact support with your number.';
      case 'Map not loading':
        return '• Confirm Google Maps API key is correct\n'
            '• Confirm Maps SDK for Android is enabled\n'
            '• Ensure billing is enabled on Google Cloud\n'
            '• Check location permissions\n'
            '• Rebuild the app (flutter clean) and run again.';
      case 'Login problems':
        return '• If email verification: open the link inside your email\n'
            '• If phone OTP: ensure SMS is enabled in Firebase Auth\n'
            '• Check SHA-1/SHA-256 in Firebase project settings\n'
            '• Contact support if blocked.';
      default:
        return 'This section will contain detailed step-by-step guides for "$title".';
    }
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x3300A082)),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.black54),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search help articles',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
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
  final VoidCallback onTap;

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
      onTap: onTap,
    );
  }
}

class _Topic {
  final String title;
  final IconData icon;
  _Topic(this.title, this.icon);
}

class _TopicsGrid extends StatelessWidget {
  final List<_Topic> items;
  final void Function(_Topic) onTap;
  const _TopicsGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (_, i) {
        final t = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(t),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x3300A082)),
            ),
            child: Row(
              children: [
                Icon(t.icon, color: const Color(0xFF00A082)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: EdgeInsets.zero,
      children: [
        _faq(
          'How do I create an account?',
          'Go to Profile → Create account / Sign in. Choose Email or Phone and follow the steps.',
          0,
        ),
        _faq(
          'Why didn’t I receive my SMS code?',
          'Check your network, confirm your number, wait 30–60 seconds, and tap Resend. If it still fails, contact support.',
          1,
        ),
        _faq(
          'How do deliveries work?',
          'Choose a store/service, add items, confirm address, and a rider is assigned for delivery.',
          2,
        ),
        _faq(
          'How do I add a delivery address?',
          'Go to Profile → Addresses. You can add Home/Work/Delivery point.',
          3,
        ),
      ],
    );
  }

  ExpansionPanelRadio _faq(String title, String body, int value) {
    return ExpansionPanelRadio(
      value: value,
      headerBuilder: (_, __) => ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Text(body, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
      ),
    );
  }
}