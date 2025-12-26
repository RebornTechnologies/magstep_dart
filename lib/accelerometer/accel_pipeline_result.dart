import 'algorithms/activity_classifier.dart';

class AccelPipelineResult {
  final int stepCount;
  final double cadence;
  final ActivityLevel activity;
  final double confidence;

  const AccelPipelineResult({
    required this.stepCount,
    required this.cadence,
    required this.activity,
    required this.confidence,
  });

  const AccelPipelineResult.empty()
    : stepCount = 0,
      cadence = 0.0,
      activity = ActivityLevel.sedentary,
      confidence = 0.0;
}
