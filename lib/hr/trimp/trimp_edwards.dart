import 'package:magstep_dart/hr/hr_sample.dart';

/// Edwards TRIMP (Training Impulse) calculation.
///
/// Edwards TRIMP estimates training load based on
/// time spent in heart rate intensity zones.
///
/// This implementation is fully equivalent to the
/// Python reference algorithm and requires only:
/// - HR samples
/// - Maximum heart rate
/// library trimp_edwards;

/// Computes Edwards TRIMP from heart rate samples.
///
/// Parameters:
/// - [samples]: Uniformly resampled HR time-series
/// - [hrMax]: Athlete's maximum heart rate
///
/// Returns:
/// - Total Edwards TRIMP score (unitless)
///
/// Zone weights:
/// - < 60% HRmax → 1
/// - 60–70% HRmax → 2
/// - 70–80% HRmax → 3
/// - 80–90% HRmax → 4
/// - ≥ 90% HRmax → 5
double trimpEdwards({required List<HrSample> samples, required double hrMax}) {
  double trimp = 0.0;

  for (final sample in samples) {
    final double intensity = sample.hr / hrMax;

    final double weight;
    if (intensity < 0.6) {
      weight = 1;
    } else if (intensity < 0.7) {
      weight = 2;
    } else if (intensity < 0.8) {
      weight = 3;
    } else if (intensity < 0.9) {
      weight = 4;
    } else {
      weight = 5;
    }

    trimp += weight;
  }

  return trimp;
}
