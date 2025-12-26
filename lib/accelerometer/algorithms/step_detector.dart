import 'dart:math' as math;

/// Peak-based step detector.

class StepDetector {
  /// Detect steps from a scalar acceleration signal.
  ///
  /// [signal]       → magnitude / zero-mean accel
  /// [timestamps]   → same length as signal (seconds)
  /// [minStepTime]  → minimum time between steps (seconds)
  /// [thresholdK]   → threshold multiplier (std-based)
  static StepDetectionResult detect({
    required List<double> signal,
    required List<double> timestamps,
    double minStepTime = 0.3,
    double thresholdK = 0.5,
  }) {
    if (signal.length < 3 || signal.length != timestamps.length) {
      return const StepDetectionResult.empty();
    }

    // -------------------------------------------------------------------------
    // 1. Compute adaptive threshold
    // -------------------------------------------------------------------------
    final mean = _mean(signal);
    final std = _std(signal, mean);
    final threshold = mean + thresholdK * std;

    // -------------------------------------------------------------------------
    // 2. Peak detection
    // -------------------------------------------------------------------------
    final stepTimes = <double>[];
    double lastStepTs = -double.infinity;

    for (int i = 1; i < signal.length - 1; i++) {
      final prev = signal[i - 1];
      final curr = signal[i];
      final next = signal[i + 1];

      final isPeak = curr > prev && curr > next && curr > threshold;

      if (!isPeak) continue;

      final ts = timestamps[i];
      if (ts - lastStepTs < minStepTime) continue;

      stepTimes.add(ts);
      lastStepTs = ts;
    }

    return StepDetectionResult(
      stepCount: stepTimes.length,
      stepTimestamps: stepTimes,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers (Python numpy equivalents)
  // ---------------------------------------------------------------------------

  static double _mean(List<double> v) {
    double sum = 0.0;
    for (final x in v) {
      sum += x;
    }
    return sum / v.length;
  }

  static double _std(List<double> v, double mean) {
    double sumSq = 0.0;
    for (final x in v) {
      final d = x - mean;
      sumSq += d * d;
    }
    return math.sqrt(sumSq / v.length);
  }
}

/// Output model for step detection
class StepDetectionResult {
  final int stepCount;
  final List<double> stepTimestamps;

  const StepDetectionResult({
    required this.stepCount,
    required this.stepTimestamps,
  });

  const StepDetectionResult.empty() : stepCount = 0, stepTimestamps = const [];
}
