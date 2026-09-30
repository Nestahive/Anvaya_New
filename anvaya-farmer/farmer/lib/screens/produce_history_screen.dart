import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'produce_verification_screen.dart';

/// Screen 5: Produce History Screen matching reference Image 5.
class ProduceHistoryScreen extends StatefulWidget {
  const ProduceHistoryScreen({super.key});

  @override
  State<ProduceHistoryScreen> createState() => _ProduceHistoryScreenState();
}

class _ProduceHistoryScreenState extends State<ProduceHistoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _batches = [
    {
      'title': 'Organic Arabica Coffee',
      'batchId': 'Batch #AG-8291',
      'date': 'Oct 24, 2023 • 09:45 AM',
      'status': 'VERIFIED',
      'type': 'coffee',
    },
    {
      'title': 'Golden Manuka Honey',
      'batchId': 'Batch #AG-7422',
      'date': 'Oct 23, 2023 • 02:15 PM',
      'status': 'PENDING',
      'type': 'honey',
    },
    {
      'title': 'Fresh Baby Spinach',
      'batchId': 'Batch #AG-1104',
      'date': 'Oct 21, 2023 • 08:30 AM',
      'status': 'REJECTED',
      'type': 'spinach',
    },
    {
      'title': 'Premium Robusta Coffee',
      'batchId': 'Batch #AG-0922',
      'date': 'Oct 19, 2023 • 11:20 AM',
      'status': 'VERIFIED',
      'type': 'coffee',
    },
    {
      'title': 'Wildflower Honey',
      'batchId': 'Batch #AG-0881',
      'date': 'Oct 15, 2023 • 04:10 PM',
      'status': 'VERIFIED',
      'type': 'honey',
    },
  ];

  List<Map<String, dynamic>> get _filteredBatches {
    return _batches.where((batch) {
      final matchesFilter = _selectedFilter == 'All' ||
          batch['status'].toString().toUpperCase() == _selectedFilter.toUpperCase() ||
          (_selectedFilter == 'Flagged' && batch['status'] == 'REJECTED');

      final matchesSearch = _searchQuery.isEmpty ||
          batch['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch['batchId'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text(
          'Verify Crop AI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProduceVerificationScreen(),
            ),
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header: "Produce History" + Filter Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produce History',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F2618),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Search Bar matching Image 5
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF161917),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF262C28),
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: AppColors.primaryGreen,
                  decoration: const InputDecoration(
                    hintText: 'Search batch ID or crop type...',
                    hintStyle: TextStyle(color: Color(0xFF6F7772), fontSize: 13.5),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6F7772), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Pills matching Image 5: [ All ] [ Verified ] [ Pending ] [ Flagged ]
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildFilterPill('All'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Verified'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterPill('Flagged'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // List of Batch Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                itemCount: _filteredBatches.length,
                itemBuilder: (context, index) {
                  final batch = _filteredBatches[index];
                  return _buildBatchCard(batch);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : const Color(0xFF161917),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFF262C28),
            width: 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBatchCard(Map<String, dynamic> batch) {
    final status = batch['status'] as String;
    Color statusColor;
    switch (status) {
      case 'VERIFIED':
        statusColor = AppColors.primaryGreen;
        break;
      case 'PENDING':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'REJECTED':
      case 'FLAGGED':
      default:
        statusColor = const Color(0xFFEF4444);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121513),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1D2420),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Crop Thumbnail with smooth illustration
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getThumbnailBg(batch['type']),
            ),
            child: Center(
              child: _getThumbnailIcon(batch['type']),
            ),
          ),
          const SizedBox(width: 14),

          // Crop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  batch['batchId'],
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      batch['date'],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThumbnailBg(String? type) {
    switch (type) {
      case 'coffee':
        return const Color(0xFFD6A97A);
      case 'honey':
        return const Color(0xFFF9E8B2);
      case 'spinach':
        return const Color(0xFF3F614E);
      default:
        return const Color(0xFF222B25);
    }
  }

  Widget _getThumbnailIcon(String? type) {
    switch (type) {
      case 'coffee':
        return const Icon(Icons.coffee_rounded, color: Color(0xFF4A2C11), size: 28);
      case 'honey':
        return const Icon(Icons.hive_rounded, color: Color(0xFF946200), size: 28);
      case 'spinach':
        return const Icon(Icons.eco_rounded, color: Color(0xFFD4EBD6), size: 28);
      default:
        return const Icon(Icons.spa_rounded, color: Colors.white, size: 28);
    }
  }
}
