import 'dart:math';

import 'detect_extrema.dart';
import 'motionless_mask.dart';
import 'pair_extrema.dart';
import 'map_pairs_to_steps.dart';

import 'filters/butterworth.dart';
import 'filters/filtfilt.dart';

import 'session_config.dart';
import 'sampling_rate.dart';

/// Raw accelerometer sample coming from the bracelet
class RawSample {
  final double ax;
  final double ay;
  final double az;
  final DateTime timestamp;

  RawSample({
    required this.ax,
    required this.ay,
    required this.az,
    required this.timestamp,
  });
}

/// Detected step event
class StepEvent {
  final DateTime timestamp;
  final double intensity;

  StepEvent({required this.timestamp, required this.intensity});
}

/// Final analysis result for a session
class SessionResult {
  final List<double> filtered;
  final List<StepEvent> steps;
  final Map<String, dynamic> metrics;

  SessionResult({
    required this.filtered,
    required this.steps,
    required this.metrics,
  });
}

/// Main session analysis pipeline
class SessionAnalysis {
  static SessionResult processSession(List<RawSample> samples) {
    if (samples.length < 2) {
      return SessionResult(filtered: [], steps: [], metrics: {});
    }

    // 1. Estimate sampling rate from timestamps (robust to BLE jitter)
    final samplingRate = estimateSamplingRate(samples);

    final config = SessionConfig(samplingRate: samplingRate);

    // 2. Compute acceleration magnitude
    final magnitudes = samples.map(_accelMagnitude).toList();

    // 3. Detect motionless regions
    final motionlessMask = MotionlessMask.detectMotionless(magnitudes);

    // 4. Zero-phase Butterworth low-pass filtering
    final filter = ButterworthFilter.lowPass(
      order: config.filterOrder,
      cutoffHz: config.cutoffHz,
      samplingRate: config.samplingRate,
    );

    final filtered = filtfilt(magnitudes, filter.b, filter.a);

    // 5. Detect extrema on filtered signal
    final allExtrema = DetectExtrema.findExtrema(filtered);

    // 6. Remove extrema during motionless periods
    final extrema = allExtrema.where((e) {
      final i = e.index;
      return i >= 0 && i < motionlessMask.length && !motionlessMask[i];
    }).toList();

    // 7. Pair extrema into step candidates
    final pairs = PairExtrema.pairExtrema(extrema);

    // 8. Map paired extrema to steps
    final steps = MapPairsToSteps.mapPairsToSteps(pairs, samples);

    // 9. Collect metrics (expand later)
    final metrics = <String, dynamic>{
      'samplingRate': samplingRate,
      'stepCount': steps.length,
    };

    return SessionResult(filtered: filtered, steps: steps, metrics: metrics);
  }

  /// Compute acceleration magnitude
  static double _accelMagnitude(RawSample s) {
    return sqrt(s.ax * s.ax + s.ay * s.ay + s.az * s.az);
  }
}
