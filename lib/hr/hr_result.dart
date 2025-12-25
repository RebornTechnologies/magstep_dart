import 'package:magstep_dart/hr/hr_sample.dart';

import 'effort/effort_segment.dart';
import 'hrr/hrr_detector.dart';
import 'time_zone/time_in_zone_summary.dart';
import 'trimp/trimp_summary.dart';
import 'vo2max/vo2max_summary.dart';

/// Aggregated heart-rate analysis results for a session.
///
/// This object is designed to be:
/// - Immutable
/// - UI-friendly
/// - Easy to serialize
///
/// It represents the full HR analytics stack computed on-device.
class HrResult {
  /// Cleaned and resampled heart rate time-series
  final List<HrSample> samples;

  /// Detected effort segments
  final List<EffortSegment> efforts;

  /// HR recovery metrics per effort
  final List<HrrResult> recoveries;

  /// Training load metrics
  final TrimpSummary trimp;

  /// Time spent in heart-rate zones
  final TimeInZoneSummary zones;

  /// VO₂max summary (nullable if not enough data)
  final Vo2MaxSummary? vo2max;

  const HrResult({
    required this.samples,
    required this.efforts,
    required this.recoveries,
    required this.trimp,
    required this.zones,
    required this.vo2max,
  });
}
