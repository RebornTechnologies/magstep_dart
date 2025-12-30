import 'dart:convert';
import 'dart:io';

import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/gyroscope/gyro_pipeline.dart';
import 'package:test/test.dart';

void main() {
  test('Export filtered Gyro (Dart)', () async {
    // -------------------------------------------------------------------------
    // Paths
    // -------------------------------------------------------------------------
    const inputPath = 'test/data/gyro.json';
    const outputPath = 'test/dart_output/gyro_filtered_dart.json';

    // -------------------------------------------------------------------------
    // Load JSON
    // -------------------------------------------------------------------------
    final rawJson = File(inputPath).readAsStringSync();
    final Map<String, dynamic> decoded = jsonDecode(rawJson);

    final payload = decoded['data']['payload'];
    final List<dynamic> samples = payload['samples'];

    final int startTimeMs = payload['startTime'];

    // -------------------------------------------------------------------------
    // Convert samples → RawSample
    // -------------------------------------------------------------------------
    final int firstSensorTs = samples.first['timeStamp'];

    final rawSamples = samples.map<RawSample>((s) {
      final int sensorTs = s['timeStamp'];

      // Sensor timestamp is in nanoseconds → convert to milliseconds
      final double deltaMs = (sensorTs - firstSensorTs) / 1e6;

      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        startTimeMs + deltaMs.round(),
      );

      return RawSample(
        timestamp: timestamp,
        x: (s['x'] as num).toDouble(),
        y: (s['y'] as num).toDouble(),
        z: (s['z'] as num).toDouble(),
      );
    }).toList();

    print('Loaded ${rawSamples.length} gyro samples');

    // -------------------------------------------------------------------------
    // Split axes (SciPy-style input arrays)
    // -------------------------------------------------------------------------
    final gx = <double>[];
    final gy = <double>[];
    final gz = <double>[];

    for (final s in rawSamples) {
      gx.add(s.x);
      gy.add(s.y);
      gz.add(s.z);
    }

    // -------------------------------------------------------------------------
    // Run Gyro Pipeline (DSP Butterworth + filtfilt)
    // -------------------------------------------------------------------------
    final pipeline = GyroPipeline();

    final result = pipeline.process(x: gx, y: gy, z: gz);

    final int n = result.x.length;
    print('Filtered $n gyro samples');

    // -------------------------------------------------------------------------
    // Serialize filtered output (Python / SciPy comparable)
    // -------------------------------------------------------------------------
    final outputJson = {
      'meta': {
        'source': 'dart',
        'sensor': 'gyro',
        'filter': {
          'type': 'butterworth_highpass',
          'cutoff_hz': 0.3,
          'fs_hz': 50.0,
          'order': 2,
          'zero_phase': true,
          'implementation': 'SOS + filtfilt (DSP core)',
        },
      },
      'samples': List.generate(n, (i) {
        return {
          'index': i,
          'gx': result.x[i],
          'gy': result.y[i],
          'gz': result.z[i],
        };
      }),
    };

    Directory('test/dart_output').createSync(recursive: true);

    File(
      outputPath,
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(outputJson));

    print('Filtered gyro output written to $outputPath');
  });
}
