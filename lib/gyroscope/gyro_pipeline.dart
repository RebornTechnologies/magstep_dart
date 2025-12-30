import '../../dsp/dsp_filter.dart';
import 'gyro_pipeline_result.dart';

/// Gyroscope signal processing pipeline.
///
/// Applies a zero-phase Butterworth high-pass filter
/// using the shared DSP core.
class GyroPipeline {
  /// High-pass filter to remove low-frequency drift
  ///
  /// NOTE:
  /// - order = 2 → filtfilt doubles it → effective 4th order
  /// - closely matches SciPy butter + filtfilt behavior
  final DspFilter _highPass = DspFilter.highPass(
    cutoffHz: 0.3,
    fsHz: 50.0,
    order: 2,
  );

  /// Process gyro axes
  GyroPipelineResult process({
    required List<double> x,
    required List<double> y,
    required List<double> z,
  }) {
    final result = _highPass.apply(x: x, y: y, z: z);

    return GyroPipelineResult(x: result.x, y: result.y, z: result.z);
  }
}
