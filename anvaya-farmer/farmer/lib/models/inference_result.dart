/// Strict conceptual inference model for Anvaya Vision Inference Engine.
class InferenceResult {
  final String status;
  final String? produce;
  final String? condition;
  final double? confidence;
  final List<String> visibleIssues;
  final String? message;

  const InferenceResult({
    required this.status,
    this.produce,
    this.condition,
    this.confidence,
    this.visibleIssues = const [],
    this.message,
  });

  bool get isVerified => status == 'VERIFIED';
  bool get isRejected => status == 'REJECTED';
  bool get isRetakeRequired => status == 'RETAKE_REQUIRED';

  /// Format confidence as integer percentage e.g. "94% Confidence"
  String get confidencePercentage {
    if (confidence == null) return '';
    final pct = (confidence! * 100).round();
    return '$pct% Confidence';
  }

  /// Capitalized condition display text e.g. "Fresh", "Damaged", "Spoiled"
  String get displayCondition {
    if (condition == null || condition!.isEmpty) return '';
    return condition![0].toUpperCase() + condition!.substring(1).toLowerCase();
  }

  factory InferenceResult.fromJson(Map<String, dynamic> json) {
    return InferenceResult(
      status: (json['status'] as String?) ?? 'RETAKE_REQUIRED',
      produce: json['produce'] as String?,
      condition: json['condition'] as String?,
      confidence: json['confidence'] != null
          ? (json['confidence'] as num).toDouble()
          : null,
      visibleIssues:
          (json['visible_issues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'produce': produce,
      'condition': condition,
      'confidence': confidence,
      'visible_issues': visibleIssues,
      'message': message,
    };
  }
}
