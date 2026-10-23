import 'package:flutter/material.dart';

import '../models/produce_batch.dart';
import '../services/batch_service.dart';
import '../theme/app_theme.dart';

/// Screen 5: Produce History Screen connected to persistent backend database.
class ProduceHistoryScreen extends StatefulWidget {
  const ProduceHistoryScreen({super.key});

  @override
  State<ProduceHistoryScreen> createState() => _ProduceHistoryScreenState();
}

class _ProduceHistoryScreenState extends State<ProduceHistoryScreen> {
  final BatchService _batchService = BatchService();

  String _selectedFilter = 'All';
  String _searchQuery = '';
  List<ProduceBatch> _batches = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _batchService.batchesUpdatedNotifier.addListener(_onBatchesUpdated);
    _loadBatches();
  }

  @override
  void dispose() {
    _batchService.batchesUpdatedNotifier.removeListener(_onBatchesUpdated);
    super.dispose();
  }

  void _onBatchesUpdated() {
    if (mounted) {
      _loadBatches(showLoading: false);
    }
  }

  Future<void> _loadBatches({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final list = await _batchService.fetchBatches();
      if (mounted) {
        setState(() {
          _batches = list;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load produce history. Please pull to refresh.';
        });
      }
    }
  }

  List<ProduceBatch> get _filteredBatches {
    return _batches.where((batch) {
      final matchesFilter =
          _selectedFilter == 'All' ||
          batch.status.toUpperCase() == _selectedFilter.toUpperCase() ||
          (_selectedFilter == 'Flagged' && batch.status.toUpperCase() == 'REJECTED');

      final matchesSearch =
          _searchQuery.isEmpty ||
          batch.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch.batchId.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  InkWell(
                    onTap: () => _loadBatches(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F2618),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Search Bar
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
                    hintStyle: TextStyle(
                      color: Color(0xFF6F7772),
                      fontSize: 13.5,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6F7772),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterPill('All'),
                  const SizedBox(width: 8),
                  _buildFilterPill('VERIFIED'),
                  const SizedBox(width: 8),
                  _buildFilterPill('PENDING'),
                  const SizedBox(width: 8),
                  _buildFilterPill('REJECTED'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Batches List
            Expanded(
              child: _isLoading && _batches.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryGreen,
                      backgroundColor: const Color(0xFF161917),
                      onRefresh: () => _loadBatches(showLoading: false),
                      child: _buildBatchesContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchesContent() {
    if (_errorMessage != null && _batches.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadBatches,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final filtered = _filteredBatches;

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161917),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF262C28)),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 28),
                ),
                const SizedBox(height: 14),
                const Text(
                  'No Produce Batches Found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register produce or verify a harvest batch to view history.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildBatchCard(filtered[index]);
      },
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
            color: isSelected
                ? AppColors.primaryGreen
                : const Color(0xFF262C28),
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

  Widget _buildBatchCard(ProduceBatch batch) {
    final status = batch.status.toUpperCase();
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
        border: Border.all(color: const Color(0xFF1D2420), width: 1.0),
      ),
      child: Row(
        children: [
          // Crop Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getThumbnailBg(batch.type ?? batch.category.toLowerCase()),
            ),
            child: Center(
              child: _getThumbnailIcon(batch.type ?? batch.category.toLowerCase()),
            ),
          ),
          const SizedBox(width: 14),

          // Crop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      batch.batchId,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (batch.quantity.isNotEmpty) ...[
                      const Text(' • ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text(
                        batch.quantity,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
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
                      batch.date,
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
    final lower = (type ?? '').toLowerCase();
    if (lower.contains('coffee')) {
      return const Color(0xFFD6A97A);
    } else if (lower.contains('honey')) {
      return const Color(0xFFF9E8B2);
    } else if (lower.contains('spinach')) {
      return const Color(0xFF3F614E);
    } else if (lower.contains('fruit') || lower.contains('mango') || lower.contains('apple') || lower.contains('guava')) {
      return const Color(0xFF5D4037);
    } else {
      return const Color(0xFF222B25);
    }
  }

  Widget _getThumbnailIcon(String? type) {
    final lower = (type ?? '').toLowerCase();
    if (lower.contains('coffee')) {
      return const Icon(Icons.coffee_rounded, color: Color(0xFF4A2C11), size: 28);
    } else if (lower.contains('honey')) {
      return const Icon(Icons.hive_rounded, color: Color(0xFF946200), size: 28);
    } else if (lower.contains('spinach')) {
      return const Icon(Icons.eco_rounded, color: Color(0xFFD4EBD6), size: 28);
    } else if (lower.contains('fruit') || lower.contains('mango') || lower.contains('apple') || lower.contains('guava')) {
      return const Icon(Icons.apple_rounded, color: Color(0xFFFFCC80), size: 28);
    } else {
      return const Icon(Icons.spa_rounded, color: Colors.white, size: 28);
    }
  }
}
