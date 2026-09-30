import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/anvaya_logo.dart';
import '../widgets/swipe_slider.dart';
import 'login_screen.dart';

/// Splash / Get Started screen matching Figma design.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _onGetStartedCompleted(BuildContext context) {
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
          // Large, soft neon green radial glow positioned at the top-right fading into black
          Positioned(
            top: -160,
            right: -80,
            child: Container(
              width: 520,
              height: 520,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.38),
                    AppColors.primaryGreen.withValues(alpha: 0.16),
                    AppColors.deepGreenGlow.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Official Anvaya Wordmark placed in the upper area matching Figma
                  const Center(
                    child: AnvayaWordmark(
                      height: 80,
                    ),
                  ),

                  const Spacer(flex: 5),

                  // Bottom Swipe-to-Confirm "Get Started" Slider
                  SwipeToConfirmSlider(
                    text: 'Get Started',
                    onConfirmed: () => _onGetStartedCompleted(context),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
