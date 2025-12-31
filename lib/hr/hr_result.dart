import 'package:magstep_dart/hr/effort/effort_segment.dart';
import 'package:magstep_dart/hr/hrr/hrr_detector.dart';
import 'package:magstep_dart/hr/hrr/hrr_result.dart';

import 'hr_sample.dart';
import 'hr_timeline_point.dart';

import 'time_zone/time_in_zone_summary.dart';
import 'trimp/trimp_summary.dart';
import 'vo2max/vo2max_summary.dart';

class HrResult {
  /// Clean, uniformly resampled HR signal
  final List<HrSample> samples;

  /// Detected effort segments
  final List<EffortSegment> efforts;

  /// HR recovery metrics computed per effort
  final List<HrrResult> recoveries;

  /// Training load metrics (Edwards + Banister)
  final TrimpSummary trimp;

  /// Time spent in heart-rate zones
  final TimeInZoneSummary zones;

  /// Estimated VO₂max (if available)
  final Vo2MaxSummary? vo2max;

  /// Per-second HR timeline enriched with:
  /// - HR sample
  /// - Zone
  /// - Incremental TRIMP
  final List<HrTimelinePoint> timeline;

  /// Whether a new HRmax was detected during this session.
  ///
  /// If true, [updatedHrMax] contains the new value
  /// and should be persisted for future sessions.
  final bool hasNewHrMax;

  /// New HRmax value detected during the session.
  ///
  /// This is only meaningful if [hasNewHrMax] is true.
  /// Otherwise, it will be null.
  final double? updatedHrMax;

  const HrResult({
    required this.samples,
    required this.efforts,
    required this.recoveries,
    required this.trimp,
    required this.zones,
    required this.vo2max,
    required this.timeline,
    required this.hasNewHrMax,
    required this.updatedHrMax,
  });
}
