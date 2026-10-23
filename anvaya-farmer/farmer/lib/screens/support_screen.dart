import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Screen: Support & 24/7 Help Center for Anvaya Farmers
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How does on-chain produce verification work?',
      'answer': 'When you scan your produce with the AI camera or NFC tag, a cryptographic hash of the crop quality, location, and timestamp is generated and committed to the Polygon blockchain ledger. This provides immutable proof of origin and quality.',
    },
    {
      'question': 'Why is my batch status showing "Pending"?',
      'answer': 'A "Pending" status indicates that the batch is awaiting automated smart contract validation or secondary sensor confirmation. Most batches are confirmed within 15–30 minutes.',
    },
    {
      'question': 'How is my Global Trust Score calculated?',
      'answer': 'Your Global Trust Score (currently 980) reflects your historical verification success rate (96%), timely delivery records, AI crop health grading consistency, and zero dispute resolutions.',
    },
    {
      'question': 'How do I link my MetaMask or hardware NFC tag?',
      'answer': 'Go to Settings > Wallet Address to link or change your Web3 wallet address. To pair a new NFC hardware batch tag, tap the central "Scan" button and hold your device near the tag.',
    },
    {
      'question': 'What should I do if my AI crop scan fails?',
      'answer': 'Ensure the produce is well-lit and placed against a neutral background. Avoid extreme shadows or blurry angles. You can retry up to 3 times before requesting manual field agronomist review.',
    },
  ];

  void _showContactSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1B231D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top subtle green radial glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.20),
                    AppColors.deepGreenGlow.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF222B24),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support & Help',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Help Center & 24/7 Agent Desk',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 24/7 Live pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112217),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '24/7 LIVE',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF19201B), height: 1),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Action Cards Grid
                        const Text(
                          'DIRECT ASSISTANCE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildContactCard(
                                icon: Icons.phone_in_talk_rounded,
                                title: 'Call Hotline',
                                subtitle: '+254 800 720 000',
                                badge: 'Toll-Free',
                                onTap: () => _showContactSnackbar(
                                  'Calling Anvaya 24/7 Farmer Hotline...',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildContactCard(
                                icon: Icons.smart_toy_rounded,
                                title: 'AI Assistant',
                                subtitle: 'Instant chat answers',
                                badge: 'Instant',
                                onTap: () => _showContactSnackbar(
                                  'Connecting to Anvaya Agronomy AI Agent...',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 0, height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildContactCard(
                                icon: Icons.mail_outline_rounded,
                                title: 'Email Support',
                                subtitle: 'support@anvaya.ag',
                                badge: '< 2h reply',
                                onTap: () => _showContactSnackbar(
                                  'Email draft opened: support@anvaya.ag',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildContactCard(
                                icon: Icons.chat_rounded,
                                title: 'WhatsApp Desk',
                                subtitle: '+254 712 345 678',
                                badge: 'Direct',
                                onTap: () => _showContactSnackbar(
                                  'Opening WhatsApp chat with Field Coordinator...',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Regional Field Officer Card
                        const Text(
                          'YOUR REGIONAL FIELD AGENT',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C100D),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF1B231D),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF152219),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.badge_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. Samuel Kiprono',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Lead Agronomist • Green Valley Sector',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.call_outlined,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () => _showContactSnackbar(
                                  'Calling Dr. Samuel Kiprono (+254 712 345 678)...',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Frequently Asked Questions
                        const Text(
                          'FREQUENTLY ASKED QUESTIONS',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _faqs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final faq = _faqs[index];
                            final isExpanded = _expandedFaqIndex == index;
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C100D),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isExpanded
                                      ? AppColors.primaryGreen.withValues(
                                          alpha: 0.4,
                                        )
                                      : const Color(0xFF1B231D),
                                  width: 1.0,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    _expandedFaqIndex = isExpanded
                                        ? null
                                        : index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              faq['question']!,
                                              style: TextStyle(
                                                color: isExpanded
                                                    ? AppColors.primaryGreen
                                                    : Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons
                                                      .keyboard_arrow_up_rounded
                                                : Icons
                                                      .keyboard_arrow_down_rounded,
                                            color: isExpanded
                                                ? AppColors.primaryGreen
                                                : AppColors.textMuted,
                                          ),
                                        ],
                                      ),
                                      if (isExpanded) ...[
                                        const SizedBox(height: 12),
                                        const Divider(
                                          color: Color(0xFF1B231D),
                                          height: 1,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          faq['answer']!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // System Status Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070B08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF162018),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_outlined,
                                    color: AppColors.primaryGreen,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Anvaya Farmer App v1.2.0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'CONNECTED',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Mainnet Node: Polygon PoS • Block Height: #19,482,104\nLatency: 28ms • All systems operational.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C100D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1B231D), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF152219),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
