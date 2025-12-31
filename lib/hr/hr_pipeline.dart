import 'package:magstep_dart/hr/hr_max/hrmax_tracker.dart';
import 'package:magstep_dart/hr/hr_sample.dart';
import 'package:magstep_dart/hr/hrr/hrr_result.dart';

import '../core/raw_sample.dart';

import '../hr/hr_resampler.dart';
import 'effort/effort_detector.dart';
import 'effort/effort_utils.dart';
import 'hrr/hrr_detector.dart';
import 'time_zone/time_in_zone.dart';
import 'time_zone/time_in_zone_summary.dart';
import 'time_zone/zone_resolver.dart';
import 'trimp/trimp_summary.dart';
import 'trimp/banister_constants.dart';
import 'trimp/banister_step.dart';
import 'vo2max/vo2max_estimator.dart';
import 'vo2max/vo2max_summary.dart';
import 'hr_timeline_point.dart';
import 'hr_result.dart';

/// Heart-rate analysis pipeline.
///
/// Converts raw HR samples into high-level physiological metrics.
class HrPipeline {
  static HrResult run({
    required List<RawSample> rawHrSamples,
    required double hrMax,
    required double hrRest,
    required Sex sex,
  }) {
    if (rawHrSamples.isEmpty) {
      throw ArgumentError('HR samples cannot be empty');
    }

    // ------------------------------------------------------------------
    // Initialize dynamic HRmax tracker
    //
    // Rules:
    // - HR must exceed current HRmax by at least `minDelta`
    // - HR must be sustained for `sustainSeconds`
    // - Prevents sensor noise from inflating HRmax
    // ------------------------------------------------------------------
    final hrMaxTracker = HrMaxTracker(
      initialHrMax: hrMax,
      sustainSeconds: 5,
      minDelta: 2.0,
    );

    // ------------------------------------------------------------------
    // 1. Convert RawSample → HrSample
    // ------------------------------------------------------------------
    final DateTime t0 = rawHrSamples.first.timestamp;

    final hrSamples = rawHrSamples.map((s) {
      final double timeSeconds =
          s.timestamp.difference(t0).inMilliseconds / 1000.0;

      final double hrValue = s.x; // HR BPM stored in x-axis

      return HrSample(timeSeconds, hrValue);
    }).toList();

    // ------------------------------------------------------------------
    // 2. Resample HR to uniform time grid (1 Hz)
    // ------------------------------------------------------------------
    final resampled = cleanAndResampleHr(samples: hrSamples);

    // ------------------------------------------------------------------
    // 3. Detect effort segments
    //
    // NOTE:
    // Effort detection intentionally uses the INITIAL HRmax.
    // This avoids retroactive effort boundary changes when HRmax updates
    // dynamically later in the session.
    // ------------------------------------------------------------------
    final efforts = detectEfforts(samples: resampled, hrMax: hrMax);

    // ------------------------------------------------------------------
    // 4. HR recovery (HRR) analysis per effort
    // ------------------------------------------------------------------
    final recoveries = <HrrResult>[];
    for (final effort in efforts) {
      final recoverySamples = extractRecoveryWindow(
        samples: resampled,
        effort: effort,
      );
      recoveries.add(computeHrr(recoverySamples));
    }

    // ------------------------------------------------------------------
    // 5. Training load (TRIMP)
    //
    // NOTE:
    // TRIMP summary uses static HRmax for session-level consistency.
    // Per-second TRIMP using dynamic HRmax is computed in the timeline.
    // ------------------------------------------------------------------
    final trimp = computeTrimpSummary(
      samples: resampled,
      hrMax: hrMax,
      hrRest: hrRest,
      sex: sex,
    );

    // ------------------------------------------------------------------
    // 5.5 Build enriched per-second HR timeline
    //
    // This timeline:
    // - Updates HRmax dynamically
    // - Resolves HR zones using current HRmax
    // - Computes Banister TRIMP increment per second
    // ------------------------------------------------------------------
    final timeline = <HrTimelinePoint>[];

    for (final s in resampled) {
      final currentHrMax = hrMaxTracker.update(s.hr);

      final zone = resolveHrZone(s.hr, currentHrMax);

      final trimpIncrement = banisterTrimpAtSample(
        hr: s.hr,
        hrRest: hrRest,
        hrMax: currentHrMax,
        sex: sex,
      );

      timeline.add(
        HrTimelinePoint(
          timeSeconds: s.time,
          sample: s,
          zone: zone,
          trimp: trimpIncrement,
          hrMax: currentHrMax,
        ),
      );
    }

    final bool hasNewHrMax = hrMaxTracker.hasUpdated;
    final double? updatedHrMax = hasNewHrMax ? hrMaxTracker.hrMax : null;

    // ------------------------------------------------------------------
    // 6. Time in heart-rate zones
    //
    // NOTE:
    // Zone summary uses INITIAL HRmax to ensure consistency
    // across sessions and reports.
    // ------------------------------------------------------------------
    final zoneStats = computeTimeInZones(samples: resampled, hrMax: hrMax);
    final zones = buildTimeInZoneSummary(zoneStats);

    // ------------------------------------------------------------------
    // 7. VO₂max estimation
    // ------------------------------------------------------------------
    final vo2Result = estimateVo2Max(samples: resampled, hrMax: hrMax);
    final vo2Summary = vo2Result != null ? buildVo2MaxSummary(vo2Result) : null;

    return HrResult(
      samples: resampled,
      efforts: efforts,
      recoveries: recoveries,
      trimp: trimp,
      zones: zones,
      vo2max: vo2Summary,
      timeline: timeline,
      hasNewHrMax: hasNewHrMax,
      updatedHrMax: updatedHrMax,
    );
  }
}
