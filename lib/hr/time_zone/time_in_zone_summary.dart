import 'time_in_zone.dart';
import 'hr_zone.dart';

/// Convenience helpers for presenting time-in-zone statistics.
///
/// This file is intended for:
/// - UI formatting
/// - API serialization
/// - Debugging and analytics
/// library time_in_zone_summary;

/// Holds formatted time-in-zone data.
class TimeInZoneSummary {
  /// Seconds per zone
  final Map<HrZone, int> seconds;

  /// Percentages per zone
  final Map<HrZone, double> percentages;

  const TimeInZoneSummary({required this.seconds, required this.percentages});
}

/// Converts raw time-in-zone results into a summary
/// suitable for UI or JSON serialization.
TimeInZoneSummary buildTimeInZoneSummary(TimeInZoneResult result) {
  final Map<HrZone, double> percentages = {};

  for (final zone in HrZone.values) {
    percentages[zone] = result.percentage(zone);
  }

  return TimeInZoneSummary(
    seconds: result.secondsPerZone,
    percentages: percentages,
  );
}
