import 'package:magstep_dart/accelerometer/accel_pipeline.dart';
import 'package:magstep_dart/accelerometer/accel_pipeline_result.dart';
import 'package:magstep_dart/accelerometer/raw/accel_sample.dart';
import 'package:magstep_dart/gyroscope/gyro_analysis_result.dart';
import 'package:magstep_dart/gyroscope/gyro_pipeline.dart';

import 'package:magstep_dart/magstep/magstep_pipeline.dart';

import '../core/raw_sample.dart';

import '../hr/hr_pipeline.dart';
import '../hr/hr_result.dart';
import '../hr/trimp/banister_constants.dart';

/// High-level session analysis orchestrator.
///
/// Coordinates all sensor pipelines and exposes
/// session-level outputs without sensor fusion.
class SessionAnalysis {
  static ({
    AccelPipelineResult accel,
    GyroAnalysisResult gyro,
    HrResult hr,
    List<double> magSteps,
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
    // Magnetometer (MagStep)
    // -------------------------------------------------------------------------
    final magMapped = _mapMagSamples(magSamples);

    final magSteps = detectStepsMag(
      t: magMapped.$1,
      signals: magMapped.$2,
      fs: magMapped.$3,
    );

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
      t: gyroMapped.$1,
      x: gyroMapped.$2,
      y: gyroMapped.$3,
      z: gyroMapped.$4,
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

    return (accel: accel, gyro: gyro, hr: hr, magSteps: magSteps);
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

  /// Maps raw gyroscope samples into:
  /// - time array (seconds since session start)
  /// - x, y, z axis arrays
  static (List<double>, List<double>, List<double>, List<double>)
  _mapGyroSamples(List<RawSample> raw) {
    if (raw.isEmpty) {
      return (const [], const [], const [], const []);
    }

    final t0 = raw.first.timestamp;

    final t = <double>[];
    final gx = <double>[];
    final gy = <double>[];
    final gz = <double>[];

    for (final s in raw) {
      final tsSeconds = s.timestamp.difference(t0).inMicroseconds / 1e6;
      t.add(tsSeconds);

      gx.add(s.x);
      gy.add(s.y);
      gz.add(s.z);
    }

    return (t, gx, gy, gz);
  }

  static (List<double>, List<List<double>>, double) _mapMagSamples(
    List<RawSample> raw,
  ) {
    if (raw.isEmpty) {
      return (const [], const [], 0.0);
    }

    final t0 = raw.first.timestamp;

    final t = <double>[];
    final x = <double>[];
    final y = <double>[];
    final z = <double>[];

    for (final s in raw) {
      final tsSeconds = s.timestamp.difference(t0).inMicroseconds / 1e6;

      t.add(tsSeconds);
      x.add(s.x);
      y.add(s.y);
      z.add(s.z);
    }

    final double fs = t.length > 1 ? 1.0 / (t[1] - t[0]) : 0.0;

    return (t, [x, y, z], fs);
  }
}
