import 'package:magstep_dart/hr/hr_sample.dart';

import 'effort_segment.dart';

/// Utility helpers for working with effort segments.
/// library effort_utils;

/// Extracts HR samples corresponding to the recovery period
/// immediately following an effort.
///
/// This is typically used as input for HRR analysis.
///
/// Parameters:
/// - [samples]: Full HR time-series
/// - [effort]: Detected effort segment
/// - [windowSeconds]: Recovery window duration
///
/// Returns:
/// - List of HR samples during recovery window
List<HrSample> extractRecoveryWindow({
  required List<HrSample> samples,
  required EffortSegment effort,
  double windowSeconds = 120,
}) {
  final double start = effort.endTime;
  final double end = start + windowSeconds;

  return samples.where((s) => s.time >= start && s.time <= end).toList();
}
