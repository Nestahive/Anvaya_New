import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/inference_result.dart';

class VisionServiceException implements Exception {
  final String message;
  final bool isRetryable;
  VisionServiceException(this.message, {this.isRetryable = false});

  @override
  String toString() => message;
}

class VisionService {
  static final VisionService _instance = VisionService._internal();
  factory VisionService() => _instance;
  VisionService._internal();

  /// Backend URL — must be reachable from the device running the app.
  ///
  /// Physical Android device (Wi-Fi): use the PC's LAN IP address.
  /// Android Emulator (AVD): use 10.0.2.2
  /// iOS Simulator / Desktop: use 127.0.0.1
  static List<String> get candidateBaseUrls {
    if (kIsWeb) {
      return ['http://localhost:8000'];
    }
    try {
      if (Platform.isAndroid) {
        return [
          'http://127.0.0.1:8000',     // Forwarded directly via adb reverse
          'http://192.168.0.104:8000', // Wi-Fi LAN IP
          'http://10.0.2.2:8000',      // Android emulator loopback
        ];
      }
    } catch (_) {}
    return ['http://127.0.0.1:8000'];
  }

  static String get defaultBaseUrl => candidateBaseUrls.first;

  String _baseUrl = defaultBaseUrl;
  String get baseUrl => _baseUrl;
  set baseUrl(String url) {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  /// Sends the selected image to POST /ai/analyze and returns the fixed normalized result.
  Future<InferenceResult> analyzeProduceImage({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final urlsToTry = <String>[_baseUrl];
    for (final cand in candidateBaseUrls) {
      if (!urlsToTry.contains(cand)) {
        urlsToTry.add(cand);
      }
    }


    for (final base in urlsToTry) {
      final uri = Uri.parse('$base/ai/analyze');

      try {
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 35),
          onTimeout: () {
            throw VisionServiceException(
              'Request timed out. Please try again.',
              isRetryable: true,
            );
          },
        );

        final responseBody = await streamedResponse.stream.bytesToString();

        if (streamedResponse.statusCode == 200) {
          _baseUrl = base; // Remember the working endpoint
          final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
          return InferenceResult.fromJson(jsonMap);
        } else if (streamedResponse.statusCode == 400 || streamedResponse.statusCode == 413) {
          try {
            final errJson = jsonDecode(responseBody);
            final detail = errJson['detail'] ?? 'Invalid image file provided.';
            throw VisionServiceException(detail);
          } catch (e) {
            if (e is VisionServiceException) rethrow;
            throw VisionServiceException('Invalid image file. Please provide a clear JPEG or PNG.');
          }
        } else if (streamedResponse.statusCode == 503) {
          throw VisionServiceException(
            'Something went wrong. Please try again.',
            isRetryable: true,
          );
        } else {
          throw VisionServiceException(
            'Something went wrong. Please try again.',
            isRetryable: true,
          );
        }
      } on VisionServiceException {
        rethrow;
      } catch (_) {
        // Try next candidate URL in case of connection / socket error
        continue;
      }
    }

    throw VisionServiceException(
      'Could not connect to backend server. Make sure the backend is running.',
      isRetryable: true,
    );
  }
}
