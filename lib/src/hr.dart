import 'dart:math';

class HeartRateProcessor {
  /// Cleans and smooths heart rate data.
  ///
  /// Steps:
  /// 1. Remove invalid values (0, negative, unrealistic)
  /// 2. Interpolate missing values
  /// 3. Apply moving average smoothing
  static List<double> processHeartRate(
    List<double> hrValues, {
    double minHr = 40,
    double maxHr = 220,
    int smoothingWindow = 5,
  }) {
    if (hrValues.isEmpty) {
      return [];
    }

    // 1. Clean invalid values
    final cleaned = hrValues.map((hr) {
      if (hr < minHr || hr > maxHr) {
        return double.nan;
      }
      return hr;
    }).toList();

    // 2. Interpolate NaN values
    final interpolated = _interpolate(cleaned);

    // 3. Smooth with moving average
    return _movingAverage(interpolated, smoothingWindow);
  }

  /// Linear interpolation of NaN values
  static List<double> _interpolate(List<double> values) {
    final result = List<double>.from(values);

    int lastValidIndex = -1;

    for (int i = 0; i < result.length; i++) {
      if (!result[i].isNaN) {
        if (lastValidIndex >= 0 && lastValidIndex + 1 < i) {
          final start = result[lastValidIndex];
          final end = result[i];
          final gap = i - lastValidIndex;

          for (int j = 1; j < gap; j++) {
            result[lastValidIndex + j] = start + (end - start) * j / gap;
          }
        }
        lastValidIndex = i;
      }
    }

    // Forward-fill leading NaNs
    for (int i = 0; i < result.length; i++) {
      if (!result[i].isNaN) {
        for (int j = 0; j < i; j++) {
          result[j] = result[i];
        }
        break;
      }
    }

    // Backward-fill trailing NaNs
    for (int i = result.length - 1; i >= 0; i--) {
      if (!result[i].isNaN) {
        for (int j = i + 1; j < result.length; j++) {
          result[j] = result[i];
        }
        break;
      }
    }

    return result;
  }

  /// Simple moving average
  static List<double> _movingAverage(List<double> signal, int window) {
    final out = List<double>.filled(signal.length, 0.0);

    for (int i = 0; i < signal.length; i++) {
      final start = max(0, i - window + 1);
      final sub = signal.sublist(start, i + 1);
      out[i] = sub.reduce((a, b) => a + b) / sub.length;
    }

    return out;
  }
}
