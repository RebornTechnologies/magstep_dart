import '../core/raw_sample.dart';

import '../magpath/magpath_pipeline.dart';
import '../magpath/magpath_result.dart';

import '../accelerometer/accelerometer_pipeline.dart';
import '../accelerometer/accelerometer_result.dart';

import '../gyroscope/gyroscope_pipeline.dart';
import '../gyroscope/gyroscope_result.dart';

import '../hr/hr_pipeline.dart';
import '../hr/hr_result.dart';
import '../hr/trimp/banister_constants.dart';

/// High-level session analysis orchestrator.
///
/// This class coordinates all sensor pipelines and produces
/// a unified session-level analysis.
///
/// Pipelines included:
/// - Magnetometer (MagPath)
/// - Accelerometer
/// - Gyroscope
/// - Heart Rate (HR)
class SessionAnalysis {
  static ({
    MagPathResult magPath,
    AccelerometerResult accelerometer,
    GyroscopeResult gyroscope,
    HrResult hr,
  })
  run({
    required List<RawSample> magSamples,
    required List<RawSample> accelSamples,
    required List<RawSample> gyroSamples,
    required List<RawSample> hrSamples,
    required double hrMax,
    required double hrRest,
    required Sex sex,
  }) {
    final mag = MagPathPipeline.run(magSamples);
    final accel = AccelerometerPipeline.run(accelSamples);
    final gyro = GyroscopePipeline.run(gyroSamples);

    final hr = HrPipeline.run(
      rawHrSamples: hrSamples,
      hrMax: hrMax,
      hrRest: hrRest,
      sex: sex,
    );

    return (magPath: mag, accelerometer: accel, gyroscope: gyro, hr: hr);
  }
}
