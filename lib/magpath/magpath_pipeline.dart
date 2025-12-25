import 'dart:math';

import 'package:magstep_dart/core/center_signal.dart';

import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/core/sampling_rate.dart';
import 'package:magstep_dart/filters/filtfilt.dart';
import 'package:magstep_dart/filters/scipy_coeffs.dart';

import 'package:magstep_dart/steps/detect_extrema.dart';
import 'package:magstep_dart/steps/map_pairs_to_steps.dart';
import 'package:magstep_dart/steps/motionless_mask.dart';
import 'package:magstep_dart/steps/pair_extrema.dart';
import 'package:magstep_dart/unity/unity_units.dart';

import 'magpath_processor.dart';
import 'magpath_result.dart';

class MagPathPipeline {
  static MagPathResult run(List<RawSample> samples) {
    if (samples.length < 2) {
      return MagPathResult(
        filtered: [],
        steps: [],
        motionlessMask: [],
        samplingRate: 0.0,
      );
    }

    // 1) Sampling rate
    final fs = estimateSamplingRateFromTimestamps(
      samples.map((s) => s.timestamp).toList(),
    );

    // 2) Raw magnitude (Unity units)
    final rawMag = samples.map(_magnitude).toList();

    // 3) Unity → microtesla
    final magUT = UnityUnits.unityMagSignalToUT(rawMag);

    // 4) Motionless mask
    final motionlessMask = MotionlessMask.detectMotionless(magUT);

    // 5) Python-equivalent preprocessing
    final magProcessed = MagPathProcessor.preprocess(
      magUT,
      motionlessMask: motionlessMask,
    );

    // 6) Center signal (Python np.mean removal)
    final centered = centerSignal(magProcessed);

    // 7) SciPy coefficients + zero-phase filtering
    final filtered = scipyFiltfilt(
      centered,
      ScipyCoeffs.magpath_3hz_50hz_b,
      ScipyCoeffs.magpath_3hz_50hz_a,
    );

    // 8) Extrema detection
    final extrema = DetectExtrema.findExtrema(filtered);

    // 9) Remove extrema during motionless
    final validExtrema = extrema
        .where(
          (e) =>
              e.index >= 0 &&
              e.index < motionlessMask.length &&
              !motionlessMask[e.index],
        )
        .toList();

    // 10) Pair extrema → steps
    final pairs = PairExtrema.pairExtrema(validExtrema);
    final steps = MapPairsToSteps.mapPairsToSteps(pairs, samples);

    return MagPathResult(
      filtered: filtered,
      steps: steps,
      motionlessMask: motionlessMask,
      samplingRate: fs,
    );
  }

  static double _magnitude(RawSample s) =>
      sqrt(s.x * s.x + s.y * s.y + s.z * s.z);
}
