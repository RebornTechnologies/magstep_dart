import 'package:magstep_dart/hr/hr_sample.dart';

import 'hrr_fitter.dart';
import 'hrr_model.dart';

/// High-level HR recovery (HRR) detection utilities.
///
/// This file is responsible for:
/// - Extracting HR recovery windows
/// - Computing HR drop metrics (30s / 60s)
/// - Fitting recovery models
/// library hrr_detector;

/// Holds extracted HR recovery metrics.
class HrrResult {
  /// Heart rate drop after 30 seconds
  final double? drop30s;

  /// Heart rate drop after 60 seconds
  final double? drop60s;

  /// Fitted exponential recovery model
  final HrrModel? model;

  const HrrResult({this.drop30s, this.drop60s, this.model});
}

/// Computes HR recovery metrics from post-exercise HR samples.
///
/// Parameters:
/// - [samples]: HR samples starting at exercise stop
///
/// Returns:
/// - [HrrResult] containing recovery metrics
HrrResult computeHrr(List<HrSample> samples) {
  if (samples.isEmpty) {
    return const HrrResult();
  }

  final double hrStart = samples.first.hr;

  double? hr30;
  double? hr60;

  for (final s in samples) {
    final t = s.time - samples.first.time;
    if (t >= 30 && hr30 == null) hr30 = s.hr;
    if (t >= 60 && hr60 == null) {
      hr60 = s.hr;
      break;
    }
  }

  final drop30 = hr30 != null ? hrStart - hr30 : null;
  final drop60 = hr60 != null ? hrStart - hr60 : null;

  final model = fitHrrModel(samples);

  return HrrResult(drop30s: drop30, drop60s: drop60, model: model);
}
