import 'dart:math';

class MotionlessMask {
  /// Detects motionless regions based on rolling standard deviation.
  ///
  /// Returns a boolean mask:
  /// - true  => motionless
  /// - false => moving
  static List<bool> detectMotionless(
    List<double> signal, {
    int windowSize = 10,
    double stdThreshold = 0.05,
  }) {
    final mask = List<bool>.filled(signal.length, false);

    if (signal.length < windowSize) {
      return mask;
    }

    for (int i = 0; i < signal.length; i++) {
      final start = max(0, i - windowSize + 1);
      final window = signal.sublist(start, i + 1);

      final mean = window.reduce((a, b) => a + b) / window.length;

      double variance = 0.0;
      for (final v in window) {
        variance += (v - mean) * (v - mean);
      }
      variance /= window.length;

      final std = sqrt(variance);

      mask[i] = std < stdThreshold;
    }

    return mask;
  }
}
