/// Utility functions related to time-series processing.
library time_utils;

/// Ensures that a list of timestamps is strictly increasing.
///
/// Polar devices (and BLE streams in general) may emit duplicate or
/// slightly out-of-order timestamps due to buffering or transmission delay.
///
/// This function enforces monotonicity by minimally shifting
/// invalid timestamps forward using a very small epsilon.
///
/// This mirrors the behavior used in the original Python implementation.
List<double> ensureMonotonicSeconds(List<double> timestamps) {
  if (timestamps.isEmpty) return [];

  final result = List<double>.from(timestamps);
  const double epsilon = 1e-9;

  for (int i = 1; i < result.length; i++) {
    if (result[i] <= result[i - 1]) {
      result[i] = result[i - 1] + epsilon;
    }
  }

  return result;
}
