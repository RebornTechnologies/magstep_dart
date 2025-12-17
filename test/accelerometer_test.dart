import 'dart:io';
import 'dart:math';

import 'package:magstep_dart/src/filters/butterworth.dart';
import 'package:magstep_dart/src/signal_analysis.dart';

import 'package:test/test.dart';

import 'utils/accel_csv_loader.dart';

void main() {
  test('Accelerometer – magnitude filter validation', () {
    // Load raw accelerometer samples (ax, ay, az, timestamp)
    final rawSamples = loadAccelerometerCsv('test/data/accelerometer.csv');

    // Convert to 1D magnitude signal
    final samples = rawSamples.map((s) {
      final magnitude = sqrt(s.ax * s.ax + s.ay * s.ay + s.az * s.az);

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

    File('test/output/accelerometer_filtered.csv').writeAsStringSync(
      result.filtered.map((v) => v.toStringAsFixed(8)).join('\n'),
    );

    expect(result.filtered.length, samples.length);
  });
}
