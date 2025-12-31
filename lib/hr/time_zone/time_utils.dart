/// Utility functions related to time-series processing.
library time_utils;

/// Ensures that a list of timestamps is strictly increasing.
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
