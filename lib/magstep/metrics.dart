import 'dart:math';

/// ---------------------------------------------------------------------------
/// metrics.dart
/// ---------------------------------------------------------------------------
///
/// Purpose:
/// --------
/// Provides **robust noise metrics** for magnetometer signals used by
/// the MagStep algorithm.
///
/// This file is a **direct Dart port** of:
/// `metrics.py` from the Python MagStep implementation.
///
/// The metrics here are used to:
/// - Estimate per-axis noise
/// - Compute SNR-like weights for axis fusion
/// - Reduce sensitivity to spikes and outliers
///
///
/// Parameters:
/// -----------
/// [x] : Input 1D signal
///
/// Returns:
/// --------
/// Mean absolute deviation from the median.
/// Returns NaN if the input is empty.
///
/// Python equivalent:
/// ------------------
/// mean(np.abs(x - median(x)))
double meanAbsDev(List<double> x) {
  if (x.isEmpty) return double.nan;

  // Copy and sort to compute median
  final List<double> sorted = List<double>.from(x)..sort();
  final int n = sorted.length;

  final double median = n.isOdd
      ? sorted[n ~/ 2]
      : 0.5 * (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]);

  double sum = 0.0;
  for (final v in x) {
    sum += (v - median).abs();
  }

  return sum / n;
}

/// Computes noise (mean absolute deviation) **per axis**.
///
/// Parameters:
/// -----------
/// [signals] : List of axis signals
///             Example: [magX, magY, magZ]
///
/// Returns:
/// --------
/// A List<double> containing one noise value per axis.
///
/// Python equivalent:
/// ------------------
/// axis_noise_absdev(signals)
List<double> axisNoiseAbsDev(List<List<double>> signals) {
  final List<double> noise = [];

  for (final sig in signals) {
    noise.add(meanAbsDev(sig));
  }

  return noise;
}
