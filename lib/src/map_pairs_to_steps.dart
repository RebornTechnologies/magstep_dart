import 'pair_extrema.dart';
import 'session_analysis.dart';

class MapPairsToSteps {
  /// Converts paired extrema into step events.
  ///
  /// Each step:
  /// - occurs at the midpoint index between the extrema
  /// - uses original sample timestamps
  /// - intensity is amplitude of the extrema pair
  static List<StepEvent> mapPairsToSteps(
    List<ExtremumPair> pairs,
    List<RawSample> samples, {
    int minStepIntervalMs = 250,
  }) {
    final steps = <StepEvent>[];

    if (pairs.isEmpty) {
      return steps;
    }

    DateTime? lastStepTime;

    for (final pair in pairs) {
      final stepIndex = ((pair.first.index + pair.second.index) / 2).round();

      // Safety check
      if (stepIndex < 0 || stepIndex >= samples.length) {
        continue;
      }

      final timestamp = samples[stepIndex].timestamp;

      // Enforce minimum time between steps
      if (lastStepTime != null) {
        final deltaMs = timestamp.difference(lastStepTime).inMilliseconds;
        if (deltaMs < minStepIntervalMs) {
          continue;
        }
      }

      steps.add(StepEvent(timestamp: timestamp, intensity: pair.amplitude));

      lastStepTime = timestamp;
    }

    return steps;
  }
}
