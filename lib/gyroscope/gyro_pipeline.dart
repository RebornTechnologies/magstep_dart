import 'dart:math' as math;

import 'package:magstep_dart/gyroscope/gyro_analysis_result.dart';

import '../../dsp/dsp_filter.dart';
import 'gyro_pipeline_result.dart';

/// Gyroscope signal processing pipeline.
///
/// Applies a zero-phase Butterworth high-pass filter
/// using the shared DSP core.
class GyroPipeline {
  final DspFilter _highPass = DspFilter.highPass(
    cutoffHz: 0.3,
    fsHz: 50.0,
    order: 2,
  );

  GyroAnalysisResult process({
    required List<double> t, // seconds
    required List<double> x,
    required List<double> y,
    required List<double> z,
  }) {
    final filtered = _highPass.apply(x: x, y: y, z: z);

    final magnitude = List<double>.generate(filtered.x.length, (i) {
      final fx = filtered.x[i];
      final fy = filtered.y[i];
      final fz = filtered.z[i];
      return math.sqrt(fx * fx + fy * fy + fz * fz);
    });

    return GyroAnalysisResult(
      t: t,
      filtered: GyroPipelineResult(x: filtered.x, y: filtered.y, z: filtered.z),
      magnitude: magnitude,
    );
  }
}
