import 'package:magstep_dart/accelerometer/accel_pipeline.dart';
import 'package:magstep_dart/accelerometer/accel_pipeline_result.dart';
import 'package:magstep_dart/accelerometer/raw/accel_sample.dart';
import 'package:magstep_dart/gyroscope/gyro_pipeline.dart';
import 'package:magstep_dart/gyroscope/gyro_pipeline_result.dart';

import '../core/raw_sample.dart';

import '../magpath/magpath_pipeline.dart';
import '../magpath/magpath_result.dart';

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
/// - Gyroscope (SciPy-matched Butterworth + filtfilt)
/// - Heart Rate (HR)
class SessionAnalysis {
  static ({
    MagPathResult magPath,
    AccelPipelineResult accel,
    GyroPipelineResult gyro,
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
    // Accelerometer
    // -------------------------------------------------------------------------
    final accel = AccelPipeline.run(rawSamples: _mapAccelSamples(accelSamples));

    // -------------------------------------------------------------------------
    // Gyroscope
    // -------------------------------------------------------------------------
    final gyroPipeline = GyroPipeline();

    final gyroMapped = _mapGyroSamples(gyroSamples);

    final gyro = gyroPipeline.process(
      x: gyroMapped.$1,
      y: gyroMapped.$2,
      z: gyroMapped.$3,
    );

    // -------------------------------------------------------------------------
    // Heart Rate
    // -------------------------------------------------------------------------
    final hr = HrPipeline.run(
      rawHrSamples: hrSamples,
      hrMax: hrMax,
      hrRest: hrRest,
      sex: sex,
    );

    return (magPath: mag, accel: accel, gyro: gyro, hr: hr);
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

  /// Maps raw gyro samples into separate X / Y / Z arrays.
  ///
  /// Time is not required for filtering, only for alignment.
  static (List<double>, List<double>, List<double>) _mapGyroSamples(
    List<RawSample> raw,
  ) {
    if (raw.isEmpty) {
      return (const [], const [], const []);
    }

    final x = <double>[];
    final y = <double>[];
    final z = <double>[];

    for (final s in raw) {
      x.add(s.x);
      y.add(s.y);
      z.add(s.z);
    }

    return (x, y, z);
  }
}
