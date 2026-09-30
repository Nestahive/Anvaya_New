import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmer/models/inference_result.dart';
import 'package:farmer/screens/produce_verification_screen.dart';

void main() {
  group('InferenceResult Model Tests', () {
    test('Verified produce parses and formats correctly', () {
      final json = {
        'status': 'VERIFIED',
        'produce': 'Tomato',
        'condition': 'fresh',
        'confidence': 0.94,
        'visible_issues': <String>[],
      };
      final result = InferenceResult.fromJson(json);
      expect(result.status, 'VERIFIED');
      expect(result.isVerified, true);
      expect(result.produce, 'Tomato');
      expect(result.displayCondition, 'Fresh');
      expect(result.confidencePercentage, '94% Confidence');
      expect(result.visibleIssues, isEmpty);
    });

    test('Rejected state parses correctly', () {
      final json = {
        'status': 'REJECTED',
        'produce': null,
        'condition': null,
        'confidence': null,
        'visible_issues': <String>[],
      };
      final result = InferenceResult.fromJson(json);
      expect(result.status, 'REJECTED');
      expect(result.isRejected, true);
      expect(result.produce, isNull);
      expect(result.condition, isNull);
      expect(result.confidence, isNull);
    });

    test('Retake required state parses correctly', () {
      final json = {
        'status': 'RETAKE_REQUIRED',
        'produce': null,
        'condition': null,
        'confidence': null,
        'visible_issues': <String>[],
      };
      final result = InferenceResult.fromJson(json);
      expect(result.status, 'RETAKE_REQUIRED');
      expect(result.isRetakeRequired, true);
    });
  });

  group('ProduceVerificationScreen UI Tests', () {
    testWidgets('Renders Produce Verification initial capture view',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProduceVerificationScreen(),
        ),
      );

      expect(find.text('Produce Verification'), findsOneWidget);
      expect(find.text('Capture Produce Image'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });
  });
}
