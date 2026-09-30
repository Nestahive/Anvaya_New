import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aegis_logo.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/metric_card.dart';
import 'farmer_profile_screen.dart';
import 'new_produce_screen.dart';
import 'placeholder_screen.dart';
import 'produce_history_screen.dart';
import 'produce_verification_screen.dart';

/// Main Application Shell incorporating Dashboard, Produce History (Image 5),
/// Center Floating QR Scanner, and Farmer Profile (Image 4).
class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentNavIndex = 1; // Default to History matching Image 5 reference

  void _navigateToPlaceholder({
    required String title,
    required String description,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceholderScreen(
          title: title,
          description: description,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildDashboardView(),
          const ProduceHistoryScreen(),
          const SizedBox.shrink(), // Center Scan handled via tap
          _buildInsightsView(),
          const FarmerProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Color(0xFF090E0B),
        border: Border(
          top: BorderSide(
            color: Color(0xFF19241D),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Item 0: New
            _buildNavItem(
              index: 0,
              icon: Icons.add_box_outlined,
              activeIcon: Icons.add_box_rounded,
              label: 'New',
            ),

            // Item 1: History (Active in Image 5)
            _buildNavItem(
              index: 1,
              icon: Icons.history_rounded,
              activeIcon: Icons.history_rounded,
              label: 'History',
            ),

            // Center Item 2: Raised Glowing Neon Green Scan Button matching Image 5
            GestureDetector(
              onTap: () {
                _navigateToPlaceholder(
                  title: 'NFC / QR Scanner',
                  description: 'Scan hardware tag or QR code to verify produce batch on-chain.',
                  icon: Icons.qr_code_scanner_rounded,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: const Text(
                      'Scan',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Item 3: Insights
            _buildNavItem(
              index: 3,
              icon: Icons.bar_chart_rounded,
              activeIcon: Icons.bar_chart_rounded,
              label: 'Insights',
            ),

            // Item 4: Settings (Profile from Image 4)
            _buildNavItem(
              index: 4,
              icon: Icons.account_circle_outlined,
              activeIcon: Icons.account_circle_rounded,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentNavIndex == index;
    final color = isSelected ? AppColors.primaryGreen : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentNavIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard / New Produce View
  Widget _buildDashboardView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Aegis Logo & Live Node
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AegisLogoMark(size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131714),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1F2B22), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Node',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Good morning, Farmer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage and verify your produce batches',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            // Main Verification Card
            AppCard(
              hasGlow: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI VERIFICATION',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verify Your Produce',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Capture your produce and use AI-powered visual verification.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          label: 'Verify AI',
                          icon: Icons.camera_alt_rounded,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProduceVerificationScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFF333E37)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_box_outlined, size: 18, color: AppColors.primaryGreen),
                          label: const Text('Add Produce'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const NewProduceScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Row
            const Row(
              children: [
                MetricCard(value: '14', label: 'TOTAL BATCHES'),
                SizedBox(width: 10),
                MetricCard(value: '13', label: 'VERIFIED', accentColor: AppColors.primaryGreen),
                SizedBox(width: 10),
                MetricCard(value: '1', label: 'PENDING', accentColor: AppColors.warning),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Insights placeholder view
  Widget _buildInsightsView() {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights_rounded, color: AppColors.primaryGreen, size: 48),
              SizedBox(height: 16),
              Text(
                'Farm Insights',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Yield trends, quality score averages, and verification rates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
