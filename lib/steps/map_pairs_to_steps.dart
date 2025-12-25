import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/core/step_event.dart';

import 'pair_extrema.dart';

class MapPairsToSteps {
  /// EXACT behavior of Python map_pairs_to_steps
  static List<StepEvent> mapPairsToSteps(
    List<ExtremumPair> pairs,
    List<RawSample> samples, {
    int minStepIntervalMs = 250,
  }) {
    final steps = <StepEvent>[];
    DateTime? lastStepTime;

    for (final pair in pairs) {
      final idx = ((pair.first.index + pair.second.index) / 2).round();

      if (idx < 0 || idx >= samples.length) continue;

      final t = samples[idx].timestamp;

      if (lastStepTime != null) {
        final dt = t.difference(lastStepTime).inMilliseconds;
        if (dt < minStepIntervalMs) continue;
      }

      steps.add(StepEvent(timestamp: t, intensity: pair.amplitude));

      lastStepTime = t;
    }

    return steps;
  }
}
