import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/anvaya_logo.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/metric_card.dart';
import 'farmer_profile_screen.dart';
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
  int _currentNavIndex = 4; // Farmer Profile screen

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
        border: Border(top: BorderSide(color: Color(0xFF19241D), width: 1.0)),
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
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.5,
                            ),
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
            Icon(isSelected ? activeIcon : icon, color: color, size: 23),
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
            // Header with Anvaya Logo & Live Node
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AnvayaLogoMark(size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131714),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1F2B22),
                      width: 0.8,
                    ),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                  AppPrimaryButton(
                    label: 'Verify AI',
                    icon: Icons.camera_alt_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProduceVerificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Row
            const Row(
              children: [
                MetricCard(value: '10', label: 'TOTAL BATCHES'),
                SizedBox(width: 10),
                MetricCard(
                  value: '5',
                  label: 'VERIFIED',
                  accentColor: AppColors.primaryGreen,
                ),
                SizedBox(width: 10),
                MetricCard(
                  value: '5',
                  label: 'PENDING',
                  accentColor: AppColors.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Working Farm Insights View
  Widget _buildInsightsView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle soft green radial glow
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.18),
                    AppColors.deepGreenGlow.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farm Insights',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Green Valley Estate • Sector B',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1511),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E2A21)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primaryGreen,
                              size: 13,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Season 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Key Metrics Grid
                  Row(
                    children: [
                      _buildInsightMetricCard(
                        title: 'Yield Efficiency',
                        value: '94.8%',
                        change: '+4.2%',
                        isPositive: true,
                        icon: Icons.trending_up_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildInsightMetricCard(
                        title: 'Avg Quality Score',
                        value: '92/100',
                        change: 'Grade A',
                        isPositive: true,
                        icon: Icons.verified_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInsightMetricCard(
                        title: 'Verification Rate',
                        value: '96%',
                        change: '14 Batches',
                        isPositive: true,
                        icon: Icons.link_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildInsightMetricCard(
                        title: 'Carbon Offset',
                        value: '1.8 T',
                        change: 'Verified Eco',
                        isPositive: true,
                        icon: Icons.eco_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Monthly Produce Yield Trend Chart
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C100D),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF1B231D),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Harvest Yield Trends (Tons)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Monthly',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Bar Chart Visualizer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildYieldBar(
                              month: 'Oct',
                              heightFactor: 0.55,
                              val: '2.8T',
                            ),
                            _buildYieldBar(
                              month: 'Nov',
                              heightFactor: 0.70,
                              val: '3.6T',
                            ),
                            _buildYieldBar(
                              month: 'Dec',
                              heightFactor: 0.88,
                              val: '4.5T',
                            ),
                            _buildYieldBar(
                              month: 'Jan',
                              heightFactor: 0.65,
                              val: '3.2T',
                            ),
                            _buildYieldBar(
                              month: 'Feb',
                              heightFactor: 1.0,
                              val: '5.1T',
                              isCurrent: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Crop Quality Breakdown
                  const Text(
                    'CROP QUALITY BREAKDOWN',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildCropProgressRow(
                    crop: 'Organic Arabica Coffee',
                    score: 98,
                    grade: 'Grade A+',
                    color: const Color(0xFFC88A58),
                  ),
                  const SizedBox(height: 10),
                  _buildCropProgressRow(
                    crop: 'Golden Manuka Honey',
                    score: 94,
                    grade: 'Grade A',
                    color: const Color(0xFFE5A93C),
                  ),
                  const SizedBox(height: 10),
                  _buildCropProgressRow(
                    crop: 'Fresh Baby Spinach',
                    score: 88,
                    grade: 'Grade B+',
                    color: AppColors.primaryGreen,
                  ),

                  const SizedBox(height: 24),

                  // Smart Agronomic Recommendations
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1812),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Agronomy Advisory',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Soil moisture at Sector B is optimal (68%). Prepare coffee batch AG-8291 for final curing before on-chain dispatch.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Expanded(
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
                Icon(icon, color: AppColors.primaryGreen, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYieldBar({
    required String month,
    required double heightFactor,
    required String val,
    bool isCurrent = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: TextStyle(
            color: isCurrent ? AppColors.primaryGreen : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primaryGreen : const Color(0xFF19251D),
            borderRadius: BorderRadius.circular(6),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            color: isCurrent ? Colors.white : AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCropProgressRow({
    required String crop,
    required int score,
    required String grade,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C100D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B231D), width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                crop,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      grade,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: const Color(0xFF18221B),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
