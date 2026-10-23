import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/produce_batch.dart';
import 'vision_service.dart';

class BatchServiceException implements Exception {
  final String message;
  BatchServiceException(this.message);

  @override
  String toString() => message;
}

class BatchService {
  static final BatchService _instance = BatchService._internal();
  factory BatchService() => _instance;
  BatchService._internal();

  final VisionService _visionService = VisionService();

  // In-memory fallback cache to ensure immediate updates and offline reliability
  final List<ProduceBatch> _localBatches = [];
  bool _hasLoadedFromBackend = false;

  /// Listeners notified when batches are created or updated
  final ValueNotifier<int> batchesUpdatedNotifier = ValueNotifier<int>(0);

  /// Fetch all batches from backend with fallback to cached data
  Future<List<ProduceBatch>> fetchBatches() async {
    final candidates = <String>[_visionService.baseUrl];
    for (final cand in VisionService.candidateBaseUrls) {
      if (!candidates.contains(cand)) {
        candidates.add(cand);
      }
    }

    for (final base in candidates) {
      final uri = Uri.parse('$base/batches');
      try {
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          _visionService.baseUrl = base;
          final List<dynamic> list = jsonDecode(res.body);
          final fetched = list.map((item) => ProduceBatch.fromJson(item as Map<String, dynamic>)).toList();
          
          _localBatches.clear();
          _localBatches.addAll(fetched);
          _hasLoadedFromBackend = true;
          return List.unmodifiable(_localBatches);
        }
      } catch (_) {
        // Try next candidate URL
        continue;
      }
    }

    // If server unreachable but we already have local/cached records, return them
    if (_hasLoadedFromBackend && _localBatches.isNotEmpty) {
      return List.unmodifiable(_localBatches);
    }

    // Default fallback initial data if server cannot be reached on first boot
    if (_localBatches.isEmpty) {
      _localBatches.addAll([
        ProduceBatch(
          batchId: 'Batch #AG-8291',
          title: 'Organic Arabica Coffee',
          category: 'Coffee',
          quantity: '250 kg',
          price: r'$14.20',
          date: 'Oct 24, 2023 • 09:45 AM',
          status: 'VERIFIED',
          condition: 'fresh',
          confidence: 0.96,
          type: 'coffee',
        ),
        ProduceBatch(
          batchId: 'Batch #AG-7422',
          title: 'Golden Manuka Honey',
          category: 'Honey',
          quantity: '120 jars',
          price: r'$28.50',
          date: 'Oct 23, 2023 • 02:15 PM',
          status: 'PENDING',
          type: 'honey',
        ),
        ProduceBatch(
          batchId: 'Batch #AG-1104',
          title: 'Fresh Baby Spinach',
          category: 'Vegetables',
          quantity: '85 kg',
          price: r'$3.80',
          date: 'Oct 21, 2023 • 08:30 AM',
          status: 'REJECTED',
          condition: 'damaged',
          confidence: 0.88,
          visibleIssues: const ['Wilting', 'Excessive moisture'],
          type: 'spinach',
        ),
      ]);
    }

    return List.unmodifiable(_localBatches);
  }

  /// Register a new batch with backend database and immediately update local cache
  Future<ProduceBatch> registerBatch({
    required String title,
    required String category,
    required String quantity,
    required String price,
    required String date,
    required String status,
    String? condition,
    double? confidence,
    List<String> visibleIssues = const [],
    String? location,
    String? description,
    String? batchId,
  }) async {
    final candidates = <String>[_visionService.baseUrl];
    for (final cand in VisionService.candidateBaseUrls) {
      if (!candidates.contains(cand)) {
        candidates.add(cand);
      }
    }

    final payload = {
      if (batchId != null) 'batch_id': batchId,
      'title': title,
      'category': category,
      'quantity': quantity,
      'price': price,
      'date': date,
      'status': status,
      'condition': condition,
      'confidence': confidence,
      'visible_issues': visibleIssues,
      'location': location,
      'description': description,
    };

    for (final base in candidates) {
      final uri = Uri.parse('$base/batches');
      try {
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200 || res.statusCode == 201) {
          _visionService.baseUrl = base;
          final Map<String, dynamic> data = jsonDecode(res.body);
          final createdBatch = ProduceBatch.fromJson(data);

          // Add to beginning of local list
          _localBatches.removeWhere((b) => b.batchId == createdBatch.batchId);
          _localBatches.insert(0, createdBatch);
          batchesUpdatedNotifier.value++;
          return createdBatch;
        }
      } catch (_) {
        continue;
      }
    }

    // If backend failed, save locally so user progress is never lost
    final fallbackBatch = ProduceBatch(
      batchId: batchId ?? 'Batch #AG-${DateTime.now().millisecondsSinceEpoch % 10000}',
      title: title,
      category: category,
      quantity: quantity,
      price: price,
      date: date,
      status: status,
      condition: condition,
      confidence: confidence,
      visibleIssues: visibleIssues,
      location: location,
      description: description,
    );
    _localBatches.insert(0, fallbackBatch);
    batchesUpdatedNotifier.value++;
    return fallbackBatch;
  }
}
