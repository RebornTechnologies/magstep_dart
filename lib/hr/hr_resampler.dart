import 'package:magstep_dart/hr/hr_sample.dart';
import 'package:magstep_dart/hr/time_zone/time_utils.dart';

/// Functions for cleaning and resampling heart rate time-series.
///
/// This file replaces Pandas + NumPy resampling logic from Python
/// with a deterministic and allocation-friendly Dart implementation.
///
/// The resampling process:
/// 1. Sorts samples by timestamp
/// 2. Ensures strictly increasing timestamps
/// 3. Resamples heart rate at a fixed time interval
/// 4. Uses linear interpolation between samples
/// library hr_resampler;

/// Cleans and resamples heart rate samples to a uniform time grid.
///
/// Parameters:
/// - [samples]: Raw HR samples from Polar (may be irregular)
/// - [dt]: Resampling interval in seconds (default = 1 second)
///
/// Returns:
/// - A uniformly sampled HR time-series suitable for:
///   - Training load calculation
///   - HR recovery detection
///   - Visualization
///
/// This method is designed to be:
/// - Fast (O(n))
/// - Safe for real-time usage
/// - Numerically stable
List<HrSample> cleanAndResampleHr({
  required List<HrSample> samples,
  double dt = 1.0,
}) {
  if (samples.isEmpty) return [];

  // Sort samples by time (in-place)
  samples.sort((a, b) => a.time.compareTo(b.time));

  // Enforce strictly increasing timestamps
  final times = ensureMonotonicSeconds(samples.map((s) => s.time).toList());
  final hrs = samples.map((s) => s.hr).toList();

  final double startTime = times.first;
  final double endTime = times.last;

  final List<HrSample> resampled = [];

  int j = 0;
  for (double t = startTime; t <= endTime; t += dt) {
    // Move pointer to the interval containing t
    while (j < times.length - 1 && times[j + 1] < t) {
      j++;
    }

    double hr;
    if (j == times.length - 1) {
      // After last known sample, hold last value
      hr = hrs[j];
    } else {
      // Linear interpolation between surrounding samples
      final double t0 = times[j];
      final double t1 = times[j + 1];
      final double h0 = hrs[j];
      final double h1 = hrs[j + 1];

      final double alpha = (t - t0) / (t1 - t0);
      hr = h0 + alpha * (h1 - h0);
    }

    resampled.add(HrSample(t, hr));
  }

  return resampled;
}
