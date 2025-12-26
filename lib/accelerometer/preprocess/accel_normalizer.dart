import 'dart:math' as math;

import '../raw/accel_sample.dart';

/// Converts 3-axis accelerometer data into a scalar magnitude signal.

class AccelNormalizer {
  /// Compute vector magnitude: sqrt(x² + y² + z²)
  static List<double> magnitude(List<AccelSample> samples) {
    return samples.map((s) {
      return math.sqrt(s.x * s.x + s.y * s.y + s.z * s.z);
    }).toList();
  }

  /// Compute magnitude and remove DC offset (mean).
  /// Useful before peak detection.
  static List<double> magnitudeZeroMean(List<AccelSample> samples) {
    if (samples.isEmpty) return [];

    final mags = magnitude(samples);

    final mean = mags.reduce((a, b) => a + b) / mags.length;

    return mags.map((v) => v - mean).toList();
  }
}
