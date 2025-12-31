import 'dart:convert';
import 'dart:io';

import 'package:magstep_dart/magstep/magstep_pipeline.dart';
import 'package:test/test.dart';

void main() {
  test('Export MagStep fused signal (Dart)', () async {
    final input =
        jsonDecode(File('test/data/magnetometer.json').readAsStringSync())
            as Map<String, dynamic>;

    final samples = input['data']['payload']['samples'] as List<dynamic>;

    final t = <double>[];
    final x = <double>[];
    final y = <double>[];
    final z = <double>[];

    final int t0 = samples.first['timeStamp'];

    for (final s in samples) {
      t.add((s['timeStamp'] - t0) / 1e9);
      x.add((s['x'] as num).toDouble());
      y.add((s['y'] as num).toDouble());
      z.add((s['z'] as num).toDouble());
    }

    final fs = 1.0 / (t[1] - t[0]);

    late List<double> fused;
    late List<double> tMoving;

    detectStepsMag(
      t: t,
      signals: [x, y, z],
      fs: fs,
      onDebugSignal: (f, tm) {
        fused = f;
        tMoving = tm;
      },
    );

    final out = {'t': tMoving, 'fused': fused};

    File(
      'test/dart_output/magstep_fused_dart.json',
    ).writeAsStringSync(jsonEncode(out));

    expect(fused.isNotEmpty, true);
  });
}
