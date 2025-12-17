import 'dart:io';

import 'package:magstep_dart/magstep_dart.dart';
import 'package:magstep_dart/src/filters/butterworth.dart';
import 'package:magstep_dart/src/signal_analysis.dart';
import 'package:test/test.dart';

import 'utils/csv_loader.dart';

void main() {
  test('MagPath – filter validation', () {
    final samples = loadSignalCsv('test/data/magPath.csv');

    final filter = ButterworthFilter.lowPass(
      order: 4,
      cutoffHz: 3.0,
      samplingRate: 50.0,
    );

    final result = SignalAnalysis.process(samples, filter);

    File('test/output/magPath_filtered.csv').writeAsStringSync(
      result.filtered.map((v) => v.toStringAsFixed(8)).join('\n'),
    );

    expect(result.filtered.length, samples.length);
  });
}
