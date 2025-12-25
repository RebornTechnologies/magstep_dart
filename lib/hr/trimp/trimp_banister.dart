import 'dart:math';

import 'package:magstep_dart/hr/hr_sample.dart';

import 'banister_constants.dart';

/// Banister TRIMP (Training Impulse) calculation.
///
/// This file implements the original Banister heart-rate based
/// training load model using heart rate reserve (HRR).
///
/// Compared to Edwards TRIMP:
/// - Uses continuous weighting instead of zones
/// - Is more physiologically accurate
/// - Reacts better to high-intensity efforts
/// library trimp_banister;

/// Computes Banister TRIMP from heart rate samples.
///
/// Parameters:
/// - [samples]: Uniformly resampled HR time-series (typically 1s)
/// - [hrRest]: Athlete's resting heart rate
/// - [hrMax]: Athlete's maximum heart rate
/// - [sex]: Athlete's biological sex (required by the model)
///
/// Returns:
/// - Total Banister TRIMP score (unitless)
///
/// Notes:
/// - Samples below resting HR contribute zero load
/// - This function assumes one sample per second
double trimpBanister({
  required List<HrSample> samples,
  required double hrRest,
  required double hrMax,
  required Sex sex,
}) {
  if (samples.isEmpty) return 0.0;

  final double scale = banisterScale(sex);
  final double exponent = banisterExponent(sex);

  double trimp = 0.0;

  for (final s in samples) {
    final double hr = s.hr;

    if (hr <= hrRest) continue;

    final double hrr = (hr - hrRest) / (hrMax - hrRest);

    // Clamp to physiological bounds
    final double hrrClamped = hrr.clamp(0.0, 1.0);

    trimp += hrrClamped * scale * exp(exponent * hrrClamped);
  }

  return trimp;
}
