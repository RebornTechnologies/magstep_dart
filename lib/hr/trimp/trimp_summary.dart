import 'package:magstep_dart/hr/hr_sample.dart';

import 'trimp_edwards.dart';
import 'trimp_banister.dart';
import 'trimp_banister_result.dart';
import 'banister_constants.dart';

/// Aggregates multiple training load metrics.
///
/// This file provides a clean interface to compute
/// different TRIMP variants from the same HR data.
/// library trimp_summary;

/// Holds multiple training load metrics for a session.
class TrimpSummary {
  /// Edwards TRIMP (zone-based)
  final double edwards;

  /// Banister TRIMP (HRR-based)
  final double banister;

  /// Time (seconds) contributing to Banister TRIMP
  ///
  /// This represents the effective physiological load duration
  /// (HR > HRrest), not just total session duration.
  final double banisterTimeSeconds;

  const TrimpSummary({
    required this.edwards,
    required this.banister,
    required this.banisterTimeSeconds,
  });

  /// Convenience getter
  double get banisterTimeMinutes => banisterTimeSeconds / 60.0;
}

/// Computes all supported TRIMP metrics from HR data.
///
/// This method is useful for:
/// - Comparing load models
/// - Analytics
/// - Debugging physiological responses
TrimpSummary computeTrimpSummary({
  required List<HrSample> samples,
  required double hrMax,
  required double hrRest,
  required Sex sex,
}) {
  final banisterResult = trimpBanister(
    samples: samples,
    hrRest: hrRest,
    hrMax: hrMax,
    sex: sex,
  );

  return TrimpSummary(
    edwards: trimpEdwards(samples: samples, hrMax: hrMax),
    banister: banisterResult.trimp,
    banisterTimeSeconds: banisterResult.activeTimeSeconds,
  );
}
