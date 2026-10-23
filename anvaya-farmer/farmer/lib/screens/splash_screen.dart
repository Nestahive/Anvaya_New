import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/anvaya_logo.dart';
import '../widgets/swipe_slider.dart';
import 'login_screen.dart';

/// Splash / Get Started screen matching Figma design.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _onGetStartedCompleted(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Large, soft neon green radial glow positioned at the top-center, fading into black
          Positioned(
            top: -200,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGreen.withValues(alpha: 0.32),
                      AppColors.primaryGreen.withValues(alpha: 0.12),
                      AppColors.deepGreenGlow.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.30, 0.60, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Large elegant Anvaya Wordmark with subtle green glow behind it
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 60,
                            spreadRadius: 30,
                          ),
                        ],
                      ),
                      child: const AnvayaWordmark(height: 110),
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
