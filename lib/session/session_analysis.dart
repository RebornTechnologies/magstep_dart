import 'package:magstep_dart/accelerometer/accel_pipeline.dart';
import 'package:magstep_dart/accelerometer/accel_pipeline_result.dart';
import 'package:magstep_dart/accelerometer/raw/accel_sample.dart';

import '../core/raw_sample.dart';

import '../magpath/magpath_pipeline.dart';
import '../magpath/magpath_result.dart';

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
    AccelPipelineResult accel,
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
    // -------------------------------------------------------------------------
    // Magnetometer
    // -------------------------------------------------------------------------
    final mag = MagPathPipeline.run(magSamples);

    // -------------------------------------------------------------------------
    // Gyroscope
    // -------------------------------------------------------------------------
    final gyro = GyroscopePipeline.run(gyroSamples);

    // -------------------------------------------------------------------------
    // Accelerometer
    // -------------------------------------------------------------------------
    final accel = AccelPipeline.run(rawSamples: _mapAccelSamples(accelSamples));

    // -------------------------------------------------------------------------
    // Heart Rate
    // -------------------------------------------------------------------------
    final hr = HrPipeline.run(
      rawHrSamples: hrSamples,
      hrMax: hrMax,
      hrRest: hrRest,
      sex: sex,
    );

    return (magPath: mag, accel: accel, gyroscope: gyro, hr: hr);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<AccelSample> _mapAccelSamples(List<RawSample> raw) {
    if (raw.isEmpty) return const [];

    final t0 = raw.first.timestamp;

    return raw.map((s) {
      final tsSeconds = s.timestamp.difference(t0).inMicroseconds / 1e6;

      return AccelSample(timestamp: tsSeconds, x: s.x, y: s.y, z: s.z);
    }).toList();
  }
}
