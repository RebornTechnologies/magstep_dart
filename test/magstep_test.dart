import 'package:magstep_dart/magstep_dart.dart';
import 'package:test/test.dart';

import 'utils/csv_loader.dart';

void main() {
  test('MagPath Polar data – end-to-end pipeline', () {
    final samples = loadMagPathCsv('test/data/magPath.csv');

    final result = SessionAnalysis.processSession(samples);

    // Pipeline integrity
    expect(result.filtered.length, samples.length);
    // expect(result.motionless.length, samples.length);

    // Step timestamps must be strictly increasing (if any)
    for (int i = 1; i < result.steps.length; i++) {
      expect(
        result.steps[i].timestamp.isAfter(result.steps[i - 1].timestamp),
        true,
      );
    }
  });
}
