import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anvaya_logo.dart';
import 'login_screen.dart';

/// Screen 4: Farmer Profile & Account Settings matching reference design.
class FarmerProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const FarmerProfileScreen({super.key, this.onBack});

  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Top Hero Banner with botanical foliage background, curved green arch and floating avatar
            _buildHeroHeader(context),

            const SizedBox(height: 20),

            // Farmer Name & ID
            const Text(
              'Pratiksha Patil',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ID: AEGIS-7729-X',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),

            const SizedBox(height: 24),

            // Global Trust Score Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const Text(
                    'GLOBAL TRUST SCORE',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Score Box with neon underline
                  Container(
                    width: 135,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C100D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1B231D),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '980',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 64,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.7,
                                ),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Three Metric Cards in a row: 14 TOTAL BATCHES, 96% VERIFIED RATIO, 2.4k EARNING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildMetricCard(value: '14', label: 'TOTAL\nBATCHES'),
                  const SizedBox(width: 10),
                  _buildMetricCard(value: '96%', label: 'VERIFIED RATIO'),
                  const SizedBox(width: 10),
                  _buildMetricCard(value: '2.4k', label: 'EARNING'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Account Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACCOUNT SETTINGS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C100D),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF1B231D),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingRow(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Wallet Address',
                          subtitle: '0x71C...4e21',
                        ),
                        const Divider(
                          color: Color(0xFF19201B),
                          height: 1,
                          indent: 64,
                        ),
                        _buildSettingRow(
                          icon: Icons.agriculture_rounded,
                          title: 'Farm Details',
                          subtitle: 'Green Valley Estate, Kenya',
                        ),
                        const Divider(
                          color: Color(0xFF19201B),
                          height: 1,
                          indent: 64,
                        ),
                        _buildSettingRow(
                          icon: Icons.help_outline_rounded,
                          title: 'Support',
                          subtitle: 'Help Center & 24/7 Agent',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Logout Action matching Image 4
            TextButton(
              onPressed: () => _handleLogout(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Logout from ANVAYA',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    const double headerHeight = 220;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Lush green botanical background container with curved bottom clipping
        ClipPath(
          clipper: _HeaderCurveClipper(),
          child: Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0A180E)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/foliage_header.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0F3820),
                          Color(0xFF092213),
                          Color(0xFF05140B),
                        ],
                      ),
                    ),
                  ),
                ),
                // Subtle gradient overlay for depth
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
                // Top-left Anvaya Logo
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 20,
                  child: const AnvayaLogoMark(
                    size: 34,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Glowing neon green arch curve border along the bottom edge
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: CustomPaint(painter: _HeaderCurveBorderPainter()),
        ),

        // Floating Farmer Avatar with green border & VERIFIED FARMER pill
        Positioned(
          bottom: -50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/farmer_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF1E3A28),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // VERIFIED FARMER Badge
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: AppColors.primaryGreen,
              //     borderRadius: BorderRadius.circular(16),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColors.primaryGreen.withValues(alpha: 0.55),
              //         blurRadius: 12,
              //       ),
              //     ],
              //   ),
              //   child: const Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(
              //         Icons.check_circle_rounded,
              //         color: Colors.black,
              //         size: 13,
              //       ),
              //       SizedBox(width: 4),
              //       Text(
              //         'VERIFIED FARMER',
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 9.5,
              //           fontWeight: FontWeight.w900,
              //           letterSpacing: 0.5,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        height: 94,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C100D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1B231D), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF141C16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF4C5850),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 45);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 25,
      size.width,
      size.height - 45,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HeaderCurveBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    final glowPaint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5)
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, size.height - 45);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 25,
      size.width,
      size.height - 45,
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
