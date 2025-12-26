import 'dart:io';

import 'package:magstep_dart/accelerometer/preprocess/accel_filter.dart';
import 'package:magstep_dart/accelerometer/preprocess/accel_normalizer.dart';
import 'package:magstep_dart/accelerometer/raw/accel_sample.dart';
import 'package:test/test.dart';

void main() {
  test('Export filtered Accel to CSV (Dart)', () async {
    // ---------------------------------------------------------------------------
    // Input / Output paths
    // ---------------------------------------------------------------------------
    final inputPath = 'test/data/accelerometer.csv';
    final outputPath = 'test/dart_output/accelerometer_filtered_dart.csv';

    // ---------------------------------------------------------------------------
    // Load CSV
    // ---------------------------------------------------------------------------
    final lines = await File(inputPath).readAsLines();

    final samples = <AccelSample>[];

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');

      final t = double.parse(parts[0]);
      final x = double.parse(parts[1]);
      final y = double.parse(parts[2]);
      final z = double.parse(parts[3]);

      samples.add(AccelSample(timestamp: t, x: x, y: y, z: z));
    }

    print('Loaded ${samples.length} accel samples');

    // ---------------------------------------------------------------------------
    // Apply filter (gravity removal)
    // ---------------------------------------------------------------------------
    final filtered = AccelFilter.highPass(samples: samples, alpha: 0.9);

    // ---------------------------------------------------------------------------
    // Magnitude + zero mean
    // ---------------------------------------------------------------------------
    final mag = AccelNormalizer.magnitude(filtered);
    final magZeroMean = AccelNormalizer.magnitudeZeroMean(filtered);

    // ---------------------------------------------------------------------------
    // Export CSV
    // ---------------------------------------------------------------------------
    final buffer = StringBuffer();
    buffer.writeln('timestamp,fx,fy,fz,magnitude,magnitude_zero_mean');

    for (int i = 0; i < filtered.length; i++) {
      final s = filtered[i];

      buffer.writeln(
        '${s.timestamp},'
        '${s.x},'
        '${s.y},'
        '${s.z},'
        '${mag[i]},'
        '${magZeroMean[i]}',
      );
    }

    await File(outputPath).writeAsString(buffer.toString());

    print('Filtered accel CSV written to: $outputPath');
  });
}
