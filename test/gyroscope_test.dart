import 'dart:io';
import 'dart:math';

import 'package:magstep_dart/src/filters/butterworth.dart';
import 'package:magstep_dart/src/signal_analysis.dart';

import 'package:test/test.dart';

import 'utils/gyro_csv_loader.dart';

void main() {
  test('Gyroscope – magnitude filter validation', () {
    // Load raw gyroscope samples (gx, gy, gz, timestamp)
    final rawSamples = loadGyroscopeCsv('test/data/gyroscope.csv');

    // Convert to angular velocity magnitude
    final samples = rawSamples.map((s) {
      final magnitude = sqrt(s.gx * s.gx + s.gy * s.gy + s.gz * s.gz);

      return SignalSample(value: magnitude, timestamp: s.timestamp);
    }).toList();

    final filter = ButterworthFilter.lowPass(
      order: 4,
      cutoffHz: 3.0,
      samplingRate: 50.0,
    );

    final result = SignalAnalysis.process(samples, filter);

    // Save filtered signal
    final outDir = Directory('test/output');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    File('test/output/gyroscope_filtered.csv').writeAsStringSync(
      result.filtered.map((v) => v.toStringAsFixed(8)).join('\n'),
    );

    expect(result.filtered.length, samples.length);
  });
}
