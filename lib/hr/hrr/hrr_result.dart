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
