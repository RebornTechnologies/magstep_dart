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
/// 5. Removes leading invalid HR values
/// 6. Re-bases time so first valid HR starts at t = 0
/// library hr_resampler;

/// Cleans and resamples heart rate samples to a uniform time grid.
///
/// Parameters:
/// - [samples]: Raw HR samples from Polar
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

  // --------------------------------------------------
  // 1. Sort samples by time (in-place)
  // --------------------------------------------------
  samples.sort((a, b) => a.time.compareTo(b.time));

  // --------------------------------------------------
  // 2. Enforce strictly increasing timestamps
  // --------------------------------------------------
  final times = ensureMonotonicSeconds(samples.map((s) => s.time).toList());
  final hrs = samples.map((s) => s.hr).toList();

  final double startTime = times.first;
  final double endTime = times.last;

  // --------------------------------------------------
  // 3. Resample to uniform grid using linear interpolation
  // --------------------------------------------------
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

      final double alpha = (t1 > t0) ? (t - t0) / (t1 - t0) : 0.0;

      hr = h0 + alpha * (h1 - h0);
    }

    resampled.add(HrSample(t, hr));
  }

  // --------------------------------------------------
  // 4. Remove leading invalid HR samples
  // --------------------------------------------------
  final int firstValidIndex = resampled.indexWhere((s) => s.hr > 0);

  if (firstValidIndex <= 0) {
    return resampled;
  }

  final trimmed = resampled.sublist(firstValidIndex);

  // --------------------------------------------------
  // 5. Re-base time so first valid HR starts at t = 0
  // --------------------------------------------------
  final double t0 = trimmed.first.time;

  return trimmed.map((s) => HrSample(s.time - t0, s.hr)).toList();
}
