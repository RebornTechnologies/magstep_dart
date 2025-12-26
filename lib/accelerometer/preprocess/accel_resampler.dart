import '../raw/accel_sample.dart';

/// Resamples accelerometer data to a fixed sampling frequency
/// using linear interpolation
class AccelResampler {
  /// Resample accelerometer samples to a fixed frequency (Hz).
  static List<AccelSample> resample({
    required List<AccelSample> samples,
    required double targetHz,
  }) {
    if (samples.length < 2) return samples;

    // -------------------------------------------------------------------------
    // 1. Ensure timestamps are strictly increasing
    // -------------------------------------------------------------------------
    final cleaned = _ensureMonotonic(samples);
    if (cleaned.length < 2) return cleaned;

    final startTs = cleaned.first.timestamp;
    final endTs = cleaned.last.timestamp;
    final dt = 1.0 / targetHz;

    // -------------------------------------------------------------------------
    // 2. Generate uniform time grid
    // -------------------------------------------------------------------------
    final resampled = <AccelSample>[];
    double t = startTs;
    int i = 0;

    while (t <= endTs && i < cleaned.length - 1) {
      while (i < cleaned.length - 2 && cleaned[i + 1].timestamp < t) {
        i++;
      }

      final s0 = cleaned[i];
      final s1 = cleaned[i + 1];

      final t0 = s0.timestamp;
      final t1 = s1.timestamp;

      if (t1 <= t0) {
        t += dt;
        continue;
      }

      final alpha = (t - t0) / (t1 - t0);

      final x = _lerp(s0.x, s1.x, alpha);
      final y = _lerp(s0.y, s1.y, alpha);
      final z = _lerp(s0.z, s1.z, alpha);

      resampled.add(AccelSample(timestamp: t, x: x, y: y, z: z));

      t += dt;
    }

    return resampled;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static List<AccelSample> _ensureMonotonic(List<AccelSample> samples) {
    final result = <AccelSample>[];
    double lastTs = -double.infinity;

    for (final s in samples) {
      if (s.timestamp > lastTs) {
        result.add(s);
        lastTs = s.timestamp;
      }
    }
    return result;
  }
}
