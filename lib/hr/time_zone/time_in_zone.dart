import 'package:magstep_dart/hr/hr_sample.dart';

import 'hr_zone.dart';

/// Computes time spent in each heart rate zone.
///
/// This file provides efficient utilities to calculate:
/// - Absolute time (seconds) per zone
/// - Percentage of total session time
///
/// Assumes uniformly resampled HR data (typically 1 sample per second).
/// library time_in_zone;

/// Holds time-in-zone statistics.
class TimeInZoneResult {
  /// Time spent in each zone (seconds)
  final Map<HrZone, int> secondsPerZone;

  /// Total duration of the session (seconds)
  final int totalSeconds;

  const TimeInZoneResult({
    required this.secondsPerZone,
    required this.totalSeconds,
  });

  /// Returns percentage of total time spent in a zone.
  double percentage(HrZone zone) {
    final seconds = secondsPerZone[zone] ?? 0;
    return totalSeconds == 0 ? 0.0 : (seconds / totalSeconds) * 100.0;
  }
}

/// Computes time-in-zone statistics from HR samples.
///
/// Parameters:
/// - [samples]: Uniformly resampled HR data
/// - [hrMax]: Athlete's maximum heart rate
///
/// Returns:
/// - [TimeInZoneResult] containing seconds per zone
TimeInZoneResult computeTimeInZones({
  required List<HrSample> samples,
  required double hrMax,
}) {
  final Map<HrZone, int> zoneCounters = {for (final z in HrZone.values) z: 0};

  for (final s in samples) {
    final intensity = s.hr / hrMax;
    final zone = zoneFromIntensity(intensity);
    zoneCounters[zone] = zoneCounters[zone]! + 1;
  }

  return TimeInZoneResult(
    secondsPerZone: zoneCounters,
    totalSeconds: samples.length,
  );
}
