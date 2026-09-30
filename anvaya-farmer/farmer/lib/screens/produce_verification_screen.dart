import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/inference_result.dart';
import '../services/vision_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'new_produce_screen.dart';

/// Produce Verification Screen: Visual Inference Engine Workflow
/// Strict implementation of Section 13 & 14 verification UI states.
class ProduceVerificationScreen extends StatefulWidget {
  const ProduceVerificationScreen({super.key});

  @override
  State<ProduceVerificationScreen> createState() =>
      _ProduceVerificationScreenState();
}

class _ProduceVerificationScreenState extends State<ProduceVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isAnalyzing = false;
  String? _errorMessage;
  bool _isRetryable = false;
  InferenceResult? _inferenceResult;

  String _guessCategory(String? produce) {
    if (produce == null) return 'Vegetables';
    final lower = produce.toLowerCase();
    if (lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('orange') ||
        lower.contains('mango') ||
        lower.contains('grape') ||
        lower.contains('berry') ||
        lower.contains('strawberry') ||
        lower.contains('lemon') ||
        lower.contains('peach') ||
        lower.contains('fruit') ||
        lower.contains('avocado') ||
        lower.contains('watermelon') ||
        lower.contains('papaya')) {
      return 'Fruits';
    } else if (lower.contains('coffee') || lower.contains('bean')) {
      return 'Coffee';
    } else if (lower.contains('rice') ||
        lower.contains('wheat') ||
        lower.contains('corn') ||
        lower.contains('maize') ||
        lower.contains('grain')) {
      return 'Grains';
    }
    return 'Vegetables';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _inferenceResult = null;
          _errorMessage = null;
          _isRetryable = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access image source. Please try again.';
        _isRetryable = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) {
      setState(() {
        _errorMessage = 'Please select or capture an image first.';
        _isRetryable = false;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _isRetryable = false;
    });

    try {
      final result = await _visionService.analyzeProduceImage(
        imageBytes: _selectedImageBytes!,
        filename: _selectedImageName ?? 'produce.jpg',
      );

      setState(() {
        _inferenceResult = result;
      });
    } on VisionServiceException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isRetryable = e.isRetryable;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isRetryable = true;
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _resetVerification() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _inferenceResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF090E0B),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Produce Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedImageBytes != null)
            TextButton.icon(
              onPressed: _resetVerification,
              icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textMuted),
              label: const Text(
                'Reset',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Header / Status description
              _buildWorkflowHeader(),

              const SizedBox(height: 18),

              // Image Capture / Upload Area
              if (_selectedImageBytes == null)
                _buildCaptureArea()
              else
                _buildImagePreviewArea(),

              const SizedBox(height: 18),

              // Error display
              if (_errorMessage != null) _buildErrorBanner(),

              // Inference Results Card (if analyzed)
              if (_inferenceResult != null) ...[
                const SizedBox(height: 8),
                _buildInferenceResultCard(_inferenceResult!),
              ],

              const SizedBox(height: 24),

              // Main Action Buttons
              if (_selectedImageBytes != null && _inferenceResult == null)
                AppPrimaryButton(
                  label: 'Analyze Produce',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isAnalyzing,
                  onPressed: _analyzeImage,
                )
              else if (_inferenceResult != null) ...[
                if (_inferenceResult!.isVerified) ...[
                  AppPrimaryButton(
                    label: 'Fill Produce Form with AI Info',
                    icon: Icons.assignment_turned_in_rounded,
                    onPressed: () {
                      final category = _guessCategory(_inferenceResult!.produce);
                      final issuesText = _inferenceResult!.visibleIssues.isNotEmpty
                          ? 'Visible Issues: ${_inferenceResult!.visibleIssues.join(", ")}'
                          : 'No visible defects.';
                      final desc =
                          'AI Verified ${_inferenceResult!.produce ?? "Produce"}.\n'
                          'Condition: ${_inferenceResult!.displayCondition}\n'
                          'Confidence: ${_inferenceResult!.confidencePercentage}\n'
                          '$issuesText';

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NewProduceScreen(
                            initialCropName: _inferenceResult!.produce != null
                                ? '${_inferenceResult!.produce} (${_inferenceResult!.displayCondition})'
                                : null,
                            initialCategory: category,
                            initialDescription: desc,
                            initialImageBytes: _selectedImageBytes,
                            inferenceResult: _inferenceResult,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF333E37)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _resetVerification,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Verify Another Batch'),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111713),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2B21), width: 0.8),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.primaryGreen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Deterministic Visual Verification for Produce Quality',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureArea() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGreen, width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.primaryGreen,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Capture Produce Image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Take a photo or upload an image of any fruit or vegetable to verify condition.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF19211C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF28362D), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewArea() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF141815),
              border: Border.all(color: const Color(0xFF26332A), width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  _selectedImageBytes!,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 20),
                      tooltip: 'Retake / Choose different image',
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _isRetryable ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_isRetryable) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the structured inference result card matching the 3 required states:
  /// 1. VERIFIED
  /// 2. REJECTED
  /// 3. RETAKE_REQUIRED
  Widget _buildInferenceResultCard(InferenceResult result) {
    if (result.isVerified) {
      return _buildVerifiedCard(result);
    } else if (result.isRejected) {
      return _buildRejectedCard();
    } else {
      return _buildRetakeRequiredCard();
    }
  }

  /// State 1: VERIFIED
  /// Display:
  /// ✓ AI VERIFIED
  /// `[Produce]`
  /// `[Condition]`
  /// `[Confidence]%` Confidence
  /// Visible Issues (if any)
  Widget _buildVerifiedCard(InferenceResult result) {
    final conditionColor = switch (result.condition?.toLowerCase()) {
      'fresh' => AppColors.primaryGreen,
      'damaged' => AppColors.warning,
      'spoiled' => AppColors.error,
      _ => AppColors.primaryGreen,
    };

    return AppCard(
      hasGlow: true,
      borderColor: AppColors.borderGreen,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge: ✓ AI VERIFIED
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI VERIFIED',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (result.confidence != null)
                Text(
                  result.confidencePercentage,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Produce Name
          Text(
            result.produce ?? 'Produce',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          // Condition Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: conditionColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  result.displayCondition,
                  style: TextStyle(
                    color: conditionColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Visible Issues List
          if (result.visibleIssues.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF222B24), thickness: 1),
            const SizedBox(height: 10),
            const Text(
              'Visible Issues',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...result.visibleIssues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6.0, right: 8.0),
                      child: Icon(Icons.circle, size: 6, color: AppColors.warning),
                    ),
                    Expanded(
                      child: Text(
                        issue,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// State 2: REJECTED
  /// Display:
  /// ✕ NO PRODUCE DETECTED
  /// Please capture a fruit or vegetable.
  Widget _buildRejectedCard() {
    return AppCard(
      borderColor: AppColors.error.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.cancel_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '✕ NO PRODUCE DETECTED',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please capture a fruit or vegetable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF333E37)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Capture Produce'),
          ),
        ],
      ),
    );
  }

  /// State 3: RETAKE_REQUIRED
  /// Display:
  /// ↻ RETAKE PHOTO
  /// The image quality is too low for reliable analysis.
  Widget _buildRetakeRequiredCard() {
    return AppCard(
      borderColor: AppColors.warning.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.replay_rounded,
                color: AppColors.warning,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '↻ RETAKE PHOTO',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The image quality is too low\nfor reliable analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF333E37)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retake Photo'),
          ),
        ],
      ),
    );
  }
}
