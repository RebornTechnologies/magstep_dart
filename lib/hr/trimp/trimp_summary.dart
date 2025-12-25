import 'package:magstep_dart/hr/hr_sample.dart';

import 'trimp_edwards.dart';
import 'trimp_banister.dart';
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

  const TrimpSummary({required this.edwards, required this.banister});
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
  return TrimpSummary(
    edwards: trimpEdwards(samples: samples, hrMax: hrMax),
    banister: trimpBanister(
      samples: samples,
      hrRest: hrRest,
      hrMax: hrMax,
      sex: sex,
    ),
  );
}
