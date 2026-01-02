import 'package:magstep_dart/gyroscope/gyro_pipeline_result.dart';

class GyroAnalysisResult {
  /// Time axis (seconds since session start)
  final List<double> t;

  /// Filtered angular velocity (rad/s or deg/s)
  final GyroPipelineResult filtered;

  /// |ω| = sqrt(x² + y² + z²)
  final List<double> magnitude;

  GyroAnalysisResult({
    required this.t,
    required this.filtered,
    required this.magnitude,
  });
}
