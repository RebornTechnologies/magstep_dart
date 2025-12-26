import 'dart:math' as math;

/// Activity levels derived from accelerometer data.

class ActivityClassifier {
  /// Classify activity based on cadence and optional signal energy.
  static ActivityResult classify({
    required double cadence, // steps per minute
    List<double>? accelSignal, // optional normalized magnitude
  }) {
    // -------------------------------------------------------------------------
    // 1. Cadence-based classification (primary)
    // -------------------------------------------------------------------------
    if (cadence <= 0) {
      return const ActivityResult(
        activity: ActivityLevel.sedentary,
        confidence: 1.0,
      );
    }

    if (cadence < 60) {
      return const ActivityResult(
        activity: ActivityLevel.sedentary,
        confidence: 0.9,
      );
    }

    if (cadence < 130) {
      return const ActivityResult(
        activity: ActivityLevel.walk,
        confidence: 0.9,
      );
    }

    // cadence >= 130
    var result = const ActivityResult(
      activity: ActivityLevel.run,
      confidence: 0.9,
    );

    // -------------------------------------------------------------------------
    // 2. Signal-energy refinement (optional)
    // -------------------------------------------------------------------------
    if (accelSignal != null && accelSignal.isNotEmpty) {
      final rms = _rms(accelSignal);

      // Python-equivalent guardrails
      if (result.activity == ActivityLevel.run && rms < 0.5) {
        result = const ActivityResult(
          activity: ActivityLevel.walk,
          confidence: 0.7,
        );
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static double _rms(List<double> v) {
    double sumSq = 0.0;
    for (final x in v) {
      sumSq += x * x;
    }
    return math.sqrt(sumSq / v.length);
  }
}

/// Activity labels
enum ActivityLevel { sedentary, walk, run }

/// Output model
class ActivityResult {
  final ActivityLevel activity;
  final double confidence; // 0.0 – 1.0

  const ActivityResult({required this.activity, required this.confidence});
}
