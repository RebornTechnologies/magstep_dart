import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:magstep_dart/core/raw_sample.dart';
import 'package:magstep_dart/hr/hr_pipeline.dart';
import 'package:magstep_dart/hr/hr_result.dart';
import 'package:magstep_dart/hr/trimp/banister_constants.dart';

void main() {
  test('HR pipeline end-to-end + export timeline CSV (Dart)', () async {
    // --------------------------------------------------
    // PATHS
    // --------------------------------------------------
    final root = Directory.current.path;
    final inputFile = File('$root/test/data/hr.json');
    final outputFile = File('$root/test/dart_output/hr_timeline_dart.csv');

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
    // BUILD RawSample LIST
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

      rawHrSamples.add(RawSample(x: hr, y: 0, z: 0, timestamp: timestamp));
    }

    expect(rawHrSamples.isNotEmpty, isTrue);

    // --------------------------------------------------
    // RUN HR PIPELINE
    // --------------------------------------------------
    final HrResult result = HrPipeline.run(
      rawHrSamples: rawHrSamples,
      hrMax: 190,
      hrRest: 60,
      sex: Sex.male,
    );

    // --------------------------------------------------
    // EXPORT TIMELINE CSV (FOR PYTHON ↔ DART COMPARISON)
    // --------------------------------------------------
    final buffer = StringBuffer();
    buffer.writeln('time_s,hr,zone,trimp,hrmax');

    for (final p in result.timeline) {
      buffer.writeln(
        '${p.timeSeconds.toStringAsFixed(3)},'
        '${p.sample.hr.toStringAsFixed(2)},'
        '${p.zone},'
        '${p.trimp.toStringAsFixed(6)},'
        '${p.hrMax.toStringAsFixed(2)}',
      );
    }

    await outputFile.create(recursive: true);
    await outputFile.writeAsString(buffer.toString());

    // --------------------------------------------------
    // DEBUG OUTPUT
    // --------------------------------------------------
    print('Dart HR timeline json written to: ${outputFile.path}');
    print('Samples (resampled): ${result.samples.length}');
    print('Is HRmax updated: ${result.hasNewHrMax}');
    if (result.hasNewHrMax) {
      print('New HRmax: ${result.updatedHrMax}');
    }
  });
}
