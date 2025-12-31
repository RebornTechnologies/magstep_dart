import 'dart:math';

import 'package:magstep_dart/hr/hr_sample.dart';
import 'banister_constants.dart';
import 'trimp_banister_result.dart';

TrimpBanisterResult trimpBanister({
  required List<HrSample> samples,
  required double hrRest,
  required double hrMax,
  required Sex sex,
}) {
  if (samples.isEmpty) {
    return const TrimpBanisterResult(trimp: 0.0, activeTimeSeconds: 0.0);
  }

  final double scale = banisterScale(sex);
  final double exponent = banisterExponent(sex);

  double trimp = 0.0;
  double activeTimeSeconds = 0.0;

  // Assumption: uniform 1 Hz sampling
  const double dt = 1.0;

  for (final s in samples) {
    final double hr = s.hr;

    if (hr <= hrRest) continue;

    final double hrr = (hr - hrRest) / (hrMax - hrRest);
    final double hrrClamped = hrr.clamp(0.0, 1.0);

    final double weight = scale * exp(exponent * hrrClamped);

    trimp += weight * dt;
    activeTimeSeconds += dt;
  }

  return TrimpBanisterResult(
    trimp: trimp,
    activeTimeSeconds: activeTimeSeconds,
  );
}
