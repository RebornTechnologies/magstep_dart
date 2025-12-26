/// Cadence calculation utilities.

class CadenceCalculator {
  /// Compute cadence (steps per minute) from step timestamps.
  ///
  /// [stepTimestamps] → seconds
  /// Returns 0 if cadence cannot be computed.
  static CadenceResult compute(List<double> stepTimestamps) {
    if (stepTimestamps.length < 2) {
      return const CadenceResult(cadence: 0.0, isValid: false);
    }

    final start = stepTimestamps.first;
    final end = stepTimestamps.last;
    final durationSec = end - start;

    if (durationSec <= 0) {
      return const CadenceResult(cadence: 0.0, isValid: false);
    }

    final steps = stepTimestamps.length;
    final cadence = (steps / durationSec) * 60.0;

    return CadenceResult(cadence: cadence, isValid: true);
  }

  /// Compute rolling cadence using a sliding time window.

  static List<double> rollingCadence({
    required List<double> stepTimestamps,
    double windowSec = 5.0,
  }) {
    if (stepTimestamps.length < 2) return const [];

    final result = <double>[];
    int startIdx = 0;

    for (int i = 0; i < stepTimestamps.length; i++) {
      final t = stepTimestamps[i];

      while (stepTimestamps[startIdx] < t - windowSec) {
        startIdx++;
        if (startIdx >= i) break;
      }

      final stepsInWindow = i - startIdx + 1;
      final cadence = (stepsInWindow / windowSec) * 60.0;
      result.add(cadence);
    }

    return result;
  }
}

/// Output model for cadence calculation
class CadenceResult {
  final double cadence; // steps per minute
  final bool isValid;

  const CadenceResult({required this.cadence, required this.isValid});
}
