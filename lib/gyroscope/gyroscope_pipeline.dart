import 'dart:math';

import 'package:magstep_dart/core/center_signal.dart';
// import 'package:magstep_dart/core/filtfilt.dart';
import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/core/sampling_rate.dart';
import 'package:magstep_dart/filters/filtfilt.dart';
import 'package:magstep_dart/filters/scipy_coeffs.dart';

import 'gyroscope_result.dart';

class GyroscopePipeline {
  static GyroscopeResult run(List<RawSample> samples) {
    if (samples.length < 2) {
      return GyroscopeResult(filtered: [], samplingRate: 0);
    }

    final fs = estimateSamplingRateFromTimestamps(
      samples.map((s) => s.timestamp).toList(),
    );

    final mag = samples
        .map((s) => sqrt(s.x * s.x + s.y * s.y + s.z * s.z))
        .toList();

    final centered = centerSignal(mag);

    // SciPy gyro filter (15 Hz @ 50 Hz)
    final filtered = scipyFiltfilt(
      centered,
      ScipyCoeffs.gyro_15hz_50hz_b,
      ScipyCoeffs.gyro_15hz_50hz_a,
    );

    return GyroscopeResult(filtered: filtered, samplingRate: fs);
  }
}
