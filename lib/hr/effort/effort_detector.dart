import 'package:magstep_dart/hr/hr_sample.dart';

import 'effort_segment.dart';
import 'effort_config.dart';

/// Detects physical effort segments from heart rate data.
///
/// This detector uses a simple and robust state machine:
///
/// States:
/// - idle (below threshold)
/// - inEffort (above threshold)
///
/// Transitions are constrained by minimum duration rules
/// to prevent noise-triggered segments.
/// library effort_detector;

/// Detects effort segments from resampled HR data.
///
/// Parameters:
/// - [samples]: Uniform HR samples (typically 1s resolution)
/// - [hrMax]: Athlete's maximum heart rate
/// - [config]: Detection configuration
///
/// Returns:
/// - List of detected [EffortSegment] objects
List<EffortSegment> detectEfforts({
  required List<HrSample> samples,
  required double hrMax,
  EffortDetectionConfig config = const EffortDetectionConfig(),
}) {
  final List<EffortSegment> efforts = [];

  bool inEffort = false;
  HrSample? effortStart;
  double lastEndTime = double.negativeInfinity;

  for (final sample in samples) {
    final double pct = sample.hr / hrMax;

    if (!inEffort) {
      // Attempt to start effort
      final bool recoverySatisfied =
          sample.time - lastEndTime >= config.minRecoveryDuration;

      if (pct >= config.startThresholdPct && recoverySatisfied) {
        inEffort = true;
        effortStart = sample;
      }
    } else {
      // Attempt to end effort
      if (pct <= config.endThresholdPct) {
        final double duration = sample.time - effortStart!.time;

        if (duration >= config.minEffortDuration) {
          efforts.add(
            EffortSegment(
              startTime: effortStart.time,
              endTime: sample.time,
              startHr: effortStart.hr,
              endHr: sample.hr,
            ),
          );

          lastEndTime = sample.time;
        }

        inEffort = false;
        effortStart = null;
      }
    }
  }

  return efforts;
}
