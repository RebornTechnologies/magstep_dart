import 'package:magstep_dart/accelerometer/accel_pipeline_result.dart';

import 'raw/accel_sample.dart';
import 'preprocess/accel_resampler.dart';
import 'preprocess/accel_filter.dart';
import 'preprocess/accel_normalizer.dart';
import 'algorithms/step_detector.dart';
import 'algorithms/cadence_calculator.dart';
import 'algorithms/activity_classifier.dart';

/// Orchestrates the full accelerometer processing chain.
class AccelPipeline {
  /// Run the accelerometer pipeline end-to-end.
  static AccelPipelineResult run({
    required List<AccelSample> rawSamples,
    double targetHz = 50.0,
    double filterAlpha = 0.9,
  }) {
    // -------------------------------------------------------------------------
    // 1. Resample (timestamp normalization)
    // -------------------------------------------------------------------------
    final resampled = AccelResampler.resample(
      samples: rawSamples,
      targetHz: targetHz,
    );

    if (resampled.length < 3) {
      return const AccelPipelineResult.empty();
    }

    // -------------------------------------------------------------------------
    // 2. High-pass filter (remove gravity)
    // -------------------------------------------------------------------------
    final filtered = AccelFilter.highPass(
      samples: resampled,
      alpha: filterAlpha,
    );

    // -------------------------------------------------------------------------
    // 3. Magnitude + zero-mean normalization
    // -------------------------------------------------------------------------
    final signal = AccelNormalizer.magnitudeZeroMean(filtered);

    // -------------------------------------------------------------------------
    // 4. Extract timestamps
    // -------------------------------------------------------------------------
    final timestamps = filtered.map((s) => s.timestamp).toList();

    // -------------------------------------------------------------------------
    // 5. Step detection
    // -------------------------------------------------------------------------
    final stepResult = StepDetector.detect(
      signal: signal,
      timestamps: timestamps,
    );

    // -------------------------------------------------------------------------
    // 6. Cadence calculation
    // -------------------------------------------------------------------------
    final cadenceResult = CadenceCalculator.compute(stepResult.stepTimestamps);

    // -------------------------------------------------------------------------
    // 7. Activity classification
    // -------------------------------------------------------------------------
    final activityResult = ActivityClassifier.classify(
      cadence: cadenceResult.cadence,
      accelSignal: signal,
    );

    // -------------------------------------------------------------------------
    // 8. Final aggregated result
    // -------------------------------------------------------------------------
    return AccelPipelineResult(
      stepCount: stepResult.stepCount,
      cadence: cadenceResult.cadence,
      activity: activityResult.activity,
      confidence: activityResult.confidence,
    );
  }
}
