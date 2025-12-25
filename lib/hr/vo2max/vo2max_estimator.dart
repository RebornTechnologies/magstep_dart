import 'package:magstep_dart/hr/hr_sample.dart';

import 'vo2max_model.dart';

/// Heart-rate based VO₂max estimation utilities.
///
/// This estimator uses the Uth–Sørensen–Overgaard–Pedersen formula:
///
///   VO₂max = 15.3 × (HRmax / HRrest)
///
/// Resting HR is estimated from low-intensity segments
/// to allow free-play (non-lab) usage.
/// library vo2max_estimator;

/// Estimates VO₂max from heart rate data.
///
/// Parameters:
/// - [samples]: Uniform HR samples
/// - [hrMax]: Athlete's maximum heart rate
/// - [restingPercentile]: Lower percentile used to estimate HRrest
///
/// Returns:
/// - [Vo2MaxResult] or null if estimation is unreliable
Vo2MaxResult? estimateVo2Max({
  required List<HrSample> samples,
  required double hrMax,
  double restingPercentile = 0.10,
}) {
  if (samples.length < 60) return null;

  // Sort HR values
  final hrs = samples.map((s) => s.hr).toList()..sort();

  // Estimate resting HR as low percentile
  final int idx = (hrs.length * restingPercentile).round().clamp(
    0,
    hrs.length - 1,
  );

  final double hrRest = hrs[idx];

  if (hrRest <= 0 || hrRest >= hrMax) return null;

  final double vo2max = 15.3 * (hrMax / hrRest);

  return Vo2MaxResult(vo2max: vo2max, hrRest: hrRest, hrMax: hrMax);
}
