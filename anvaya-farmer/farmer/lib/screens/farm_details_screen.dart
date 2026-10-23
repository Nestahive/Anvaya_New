import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Farm Details screen displaying comprehensive node information for Green Valley Estate, Kenya.
class FarmDetailsScreen extends StatelessWidget {
  const FarmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Farm Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF131714),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Verified Node',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C100D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1B231D), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF141C16),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.4,
                            ),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
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
                              'Green Valley Estate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Kenya • Rift Valley Highlands',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Section: 5 total batches & 90% verified ratio
            Row(
              children: [
                _buildStatCard(value: '5', label: 'TOTAL\nBATCHES'),
                const SizedBox(width: 10),
                _buildStatCard(value: '90%', label: 'VERIFIED\nRATIO'),
                const SizedBox(width: 10),
                _buildStatCard(value: 'Grade A', label: 'AVG QUALITY\nSCORE'),
              ],
            ),

            const SizedBox(height: 24),

            // Farm Information Section
            const Text(
              'FARM INFORMATION',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C100D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF1B231D), width: 1.0),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.map_outlined,
                    title: 'Location & Altitude',
                    subtitle: 'Green Valley Estate, Nakuru County, Kenya\n1,850m Above Sea Level',
                  ),
                  const Divider(
                    color: Color(0xFF19201B),
                    height: 1,
                    indent: 64,
                  ),
                  _buildInfoTile(
                    icon: Icons.landscape_outlined,
                    title: 'Farm Size & Soil',
                    subtitle:
                        '45 Acres Cultivated • Rich Volcanic Loam (pH 6.4)',
                  ),
                  const Divider(
                    color: Color(0xFF19201B),
                    height: 1,
                    indent: 64,
                  ),
                  _buildInfoTile(
                    icon: Icons.eco_outlined,
                    title: 'Primary Crops',
                    subtitle: 'Avocados (Hass), Arabica Coffee, Macadamia',
                  ),
                  const Divider(
                    color: Color(0xFF19201B),
                    height: 1,
                    indent: 64,
                  ),
                  _buildInfoTile(
                    icon: Icons.water_drop_outlined,
                    title: 'Irrigation & Power',
                    subtitle:
                        'Solar Powered Drip Irrigation & Spring Reservoir',
                  ),
                  const Divider(
                    color: Color(0xFF19201B),
                    height: 1,
                    indent: 64,
                  ),
                  _buildInfoTile(
                    icon: Icons.verified_outlined,
                    title: 'Certifications',
                    subtitle: 'GlobalG.A.P. Certified • Rainforest Alliance • Anvaya Node',
                  ),
                  const Divider(
                    color: Color(0xFF19201B),
                    height: 1,
                    indent: 64,
                  ),
                  _buildInfoTile(
                    icon: Icons.qr_code_rounded,
                    title: 'Node Identifier',
                    subtitle: 'NODE-KEN-GV-7729 • Manager: Pratiksha Patil',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
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
                fontSize: 22,
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
