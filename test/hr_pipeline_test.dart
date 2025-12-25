import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/hr/hr_pipeline.dart';
import 'package:magstep_dart/hr/hr_result.dart';
import 'package:magstep_dart/hr/trimp/banister_constants.dart';

void main() {
  test('Export filtered HR to CSV (Dart)', () async {
    // --------------------------------------------------
    // PATHS
    // --------------------------------------------------
    final root = Directory.current.path;
    final inputFile = File('$root/test/data/hr.json');
    final outputFile = File('$root/test/dart_output/hr_filtered_dart.csv');

    expect(inputFile.existsSync(), isTrue);

    // --------------------------------------------------
    // LOAD RAW POLAR HR JSON
    // --------------------------------------------------
    final rawJson =
        jsonDecode(await inputFile.readAsString()) as Map<String, dynamic>;

    final payload = rawJson['data']['payload'];
    final int startTimeMs = payload['startTime'];
    final List samples = payload['samples'];

    // --------------------------------------------------
    // BUILD RawSample LIST (MATCH PYTHON)
    // --------------------------------------------------
    final List<RawSample> rawHrSamples = [];

    for (int i = 0; i < samples.length; i++) {
      final s = samples[i] as Map<String, dynamic>;
      if (!s.containsKey('hr')) continue;

      final double hr = (s['hr'] as num).toDouble();

      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        startTimeMs + i * 1000,
        isUtc: true,
      );

      rawHrSamples.add(
        RawSample(
          x: hr, // HR BPM stored in x-axis
          y: 0,
          z: 0,
          timestamp: timestamp,
        ),
      );
    }

    expect(rawHrSamples.isNotEmpty, isTrue);

    // --------------------------------------------------
    // RUN HR PIPELINE (CORRECT SIGNATURE)
    // --------------------------------------------------
    final HrResult result = HrPipeline.run(
      rawHrSamples: rawHrSamples,
      hrMax: 190, // <-- must be fixed to compare Python/Dart
      hrRest: 60,
      sex: Sex.male,
    );

    // --------------------------------------------------
    // EXPORT RESAMPLED HR (PIPELINE OUTPUT)
    // --------------------------------------------------
    final buffer = StringBuffer();
    buffer.writeln('time_s,hr_filtered');

    for (final sample in result.samples) {
      final t = sample.time.toStringAsFixed(6);
      final hr = sample.hr.isNaN ? '' : sample.hr.toStringAsFixed(6);

      buffer.writeln('$t,$hr');
    }

    await outputFile.writeAsString(buffer.toString());

    print('✅ Dart HR CSV written to: ${outputFile.path}');
    print('🔢 Samples: ${result.samples.length}');
  });
}
