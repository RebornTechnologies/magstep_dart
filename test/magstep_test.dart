import 'dart:io';

import 'package:magstep_dart/filters/filtfilt.dart';
import 'package:magstep_dart/filters/butterworth.dart';

import 'package:test/test.dart';

import 'utils/csv_loader.dart';

void main() {
  group('DSP filter validation', () {
    late Directory outputDir;

    setUpAll(() {
      outputDir = Directory('test/dart_output');
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
    });

    test('MagPath – filter validation', () {
      // Scalar signal ONLY (matches Python exactly)
      final signal = loadScalarCsv('test/data/magPath.csv');

      final filter = ButterworthFilter.lowPass(
        order: 4,
        cutoffHz: 3.0,
        samplingRate: 50.0,
      );

      final filtered = scipyFiltfilt(signal, filter.b, filter.a);

      File(
        'test/dart_output/magPath_filtered.csv',
      ).writeAsStringSync(filtered.map((v) => v.toStringAsFixed(8)).join('\n'));

      expect(filtered.length, signal.length);
    });

    test('Accelerometer – magnitude filter validation', () {
      // CSV already contains scalar magnitude (NOT ax, ay, az)
      final signal = loadScalarCsv('test/data/accelerometer.csv');

      final filter = ButterworthFilter.lowPass(
        order: 4,
        cutoffHz: 3.0,
        samplingRate: 50.0,
      );

      final filtered = scipyFiltfilt(signal, filter.b, filter.a);

      File(
        'test/dart_output/accelerometer_filtered.csv',
      ).writeAsStringSync(filtered.map((v) => v.toStringAsFixed(8)).join('\n'));

      expect(filtered.length, signal.length);
    });

    test('Gyroscope – magnitude filter validation', () {
      // CSV already contains scalar magnitude (NOT gx, gy, gz)
      final signal = loadScalarCsv('test/data/gyroscope.csv');

      final filter = ButterworthFilter.lowPass(
        order: 4,
        cutoffHz: 3.0,
        samplingRate: 50.0,
      );

      final filtered = scipyFiltfilt(signal, filter.b, filter.a);

      File(
        'test/dart_output/gyroscope_filtered.csv',
      ).writeAsStringSync(filtered.map((v) => v.toStringAsFixed(8)).join('\n'));

      expect(filtered.length, signal.length);
    });
  });
}
