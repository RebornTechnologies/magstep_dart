import '../raw/accel_sample.dart';

/// Accelerometer filter utilities.

class AccelFilter {
  /// Applies a low-pass filter to estimate gravity and
  /// returns dynamic acceleration (accel - gravity).
  ///
  /// alpha controls smoothing:
  /// - 0.8–0.9 → walking
  /// - 0.9–0.95 → running
  static List<AccelSample> highPass({
    required List<AccelSample> samples,
    double alpha = 0.9,
  }) {
    if (samples.isEmpty) return samples;

    double gx = samples.first.x;
    double gy = samples.first.y;
    double gz = samples.first.z;

    final filtered = <AccelSample>[];

    for (final s in samples) {
      // -----------------------------------------------------------------------
      // Low-pass filter (gravity estimation)
      // gravity = alpha * gravity + (1 - alpha) * accel
      // -----------------------------------------------------------------------
      gx = alpha * gx + (1 - alpha) * s.x;
      gy = alpha * gy + (1 - alpha) * s.y;
      gz = alpha * gz + (1 - alpha) * s.z;

      // -----------------------------------------------------------------------
      // High-pass output (dynamic acceleration)
      // -----------------------------------------------------------------------
      final dx = s.x - gx;
      final dy = s.y - gy;
      final dz = s.z - gz;

      filtered.add(AccelSample(timestamp: s.timestamp, x: dx, y: dy, z: dz));
    }

    return filtered;
  }

  /// Pure low-pass filter (gravity only).
  /// Matches Python low_pass() helper if used independently.
  static List<AccelSample> lowPass({
    required List<AccelSample> samples,
    double alpha = 0.9,
  }) {
    if (samples.isEmpty) return samples;

    double gx = samples.first.x;
    double gy = samples.first.y;
    double gz = samples.first.z;

    final filtered = <AccelSample>[];

    for (final s in samples) {
      gx = alpha * gx + (1 - alpha) * s.x;
      gy = alpha * gy + (1 - alpha) * s.y;
      gz = alpha * gz + (1 - alpha) * s.z;

      filtered.add(AccelSample(timestamp: s.timestamp, x: gx, y: gy, z: gz));
    }

    return filtered;
  }
}
