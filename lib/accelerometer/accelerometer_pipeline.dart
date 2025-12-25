import 'dart:math';

import 'package:magstep_dart/core/center_signal.dart';
import 'package:magstep_dart/core/filtfilt.dart';
import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/core/sampling_rate.dart';
import 'package:magstep_dart/filters/filtfilt.dart';
import 'package:magstep_dart/filters/scipy_coeffs.dart';

import 'accelerometer_result.dart';

class AccelerometerPipeline {
  static AccelerometerResult run(List<RawSample> samples) {
    if (samples.length < 2) {
      return AccelerometerResult(filtered: [], samplingRate: 0);
    }

    final fs = estimateSamplingRateFromTimestamps(
      samples.map((s) => s.timestamp).toList(),
    );

    // Python magnitude
    final mag = samples
        .map((s) => sqrt(s.x * s.x + s.y * s.y + s.z * s.z))
        .toList();

    // Remove DC (Python exact)
    final centered = centerSignal(mag);

    // SciPy accel filter (20 Hz @ 50 Hz)
    final filtered = scipyFiltfilt(
      centered,
      ScipyCoeffs.accel_20hz_50hz_b,
      ScipyCoeffs.accel_20hz_50hz_a,
    );

    return AccelerometerResult(filtered: filtered, samplingRate: fs);
  }
}
