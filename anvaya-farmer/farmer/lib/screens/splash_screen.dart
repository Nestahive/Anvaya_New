import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aegis_logo.dart';
import 'login_screen.dart';

/// Splash / Get Started screen matching reference Image 1.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _onGetStartedPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Prominent upper-right neon green radial glow matching Image 1
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.35),
                    AppColors.deepGreenGlow.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Center Branding Wordmark matching Image 1
                  const Center(
                    child: AegisWordmark(
                      height: 72,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Bottom Pill-shaped "Get Started" Button
                  _buildGetStartedButton(context),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF141715),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color(0xFF222724),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => _onGetStartedPressed(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Left Neon Green Circle with Black Arrow and soft glow
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),

                // Center Text: "Get Started"
                const Expanded(
                  child: Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // Right Triple Chevron: >>>
                const Padding(
                  padding: EdgeInsets.only(right: 18.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_right_rounded, color: Color(0x5594A3B8), size: 18),
                      Icon(Icons.chevron_right_rounded, color: Color(0x9994A3B8), size: 18),
                      Icon(Icons.chevron_right_rounded, color: Color(0xFFFFFFFF), size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
