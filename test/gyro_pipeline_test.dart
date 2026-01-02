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

      // ns → ms (matches Python)
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
    // Build time + axis arrays
    // -------------------------------------------------------------------------
    final t = <double>[];
    final gx = <double>[];
    final gy = <double>[];
    final gz = <double>[];

    for (int i = 0; i < rawSamples.length; i++) {
      t.add(i.toDouble());
      gx.add(rawSamples[i].x);
      gy.add(rawSamples[i].y);
      gz.add(rawSamples[i].z);
    }

    // -------------------------------------------------------------------------
    // Run Gyro Pipeline (DSP + analysis)
    // -------------------------------------------------------------------------
    final pipeline = GyroPipeline();

    final result = pipeline.process(t: t, x: gx, y: gy, z: gz);

    final int n = result.t.length;
    print('Filtered $n gyro samples');

    // -------------------------------------------------------------------------
    // Serialize output
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
          't': result.t[i], // index
          'gx': result.filtered.x[i],
          'gy': result.filtered.y[i],
          'gz': result.filtered.z[i],
          'mag': result.magnitude[i],
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
