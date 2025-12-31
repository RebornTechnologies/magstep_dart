import 'dart:math';

/// ---------------------------------------------------------------------------
/// motionless_mask.dart
/// ---------------------------------------------------------------------------
///
/// Purpose:
/// --------
/// Detects **motionless (stationary) segments** in a 1D signal using a
/// rolling, center-aligned window.
///
/// This is a **direct port** of the Python function:
/// `motionless_mask()` from `motionless_mask.py` in the MagStep pipeline.
///
/// The algorithm identifies time periods where the signal shows
/// **very low local variability**, indicating no meaningful motion.
///
///
/// Algorithm (exact Python parity):
/// --------------------------------
/// 1. Convert window duration from seconds → samples
/// 2. Compute a **centered rolling median**
/// 3. Compute a **centered rolling mean absolute deviation**
/// 4. Mark samples as motionless if deviation < threshold
///
/// Notes:
/// ------
/// - Partial windows are used at signal edges (min_periods = 1)
/// - No optimization is applied to preserve numerical parity
/// - Designed for correctness first, performance later
///
/// ---------------------------------------------------------------------------

/// Returns a boolean mask indicating motionless samples.
///
/// Parameters:
/// -----------
/// [y]      : Input 1D signal (magnetometer axis or fused signal)
/// [thrUT]  : Motion threshold in microtesla (µT)
/// [winSec] : Rolling window duration in seconds
/// [fs]     : Sampling frequency in Hz
///
/// Returns:
/// --------
/// A List<bool> where:
/// - true  → motionless (stationary)
/// - false → moving
///
/// This function is a **1-to-1 translation** of the Python implementation.
List<bool> motionlessMask(
  List<double> y,
  double thrUT,
  double winSec,
  double fs,
) {
  final int n = y.length;

  // Edge case: empty signal
  if (n == 0) return <bool>[];

  // Window size in samples (same logic as Python)
  final int w = max(1, (winSec * fs).round());
  final int half = w ~/ 2;

  // -------------------------------------------------------------------------
  // Step 1: Centered rolling median
  // -------------------------------------------------------------------------
  final List<double> med = List.filled(n, 0.0);

  for (int i = 0; i < n; i++) {
    final int start = max(0, i - half);
    final int end = min(n, i + half + 1);

    // Copy + sort window (required for median)
    final window = y.sublist(start, end)..sort();
    final int m = window.length;

    // Median computation (odd / even length)
    med[i] = (m.isOdd)
        ? window[m ~/ 2]
        : 0.5 * (window[m ~/ 2 - 1] + window[m ~/ 2]);
  }

  // -------------------------------------------------------------------------
  // Step 2: Centered rolling mean absolute deviation
  // -------------------------------------------------------------------------
  final List<double> dev = List.filled(n, 0.0);

  for (int i = 0; i < n; i++) {
    final int start = max(0, i - half);
    final int end = min(n, i + half + 1);

    double sum = 0.0;
    for (int j = start; j < end; j++) {
      sum += (y[j] - med[j]).abs();
    }

    dev[i] = sum / (end - start);
  }

  // -------------------------------------------------------------------------
  // Step 3: Thresholding → motionless mask
  // -------------------------------------------------------------------------
  return dev.map((v) => v < thrUT).toList();
}
