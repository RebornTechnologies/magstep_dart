import 'dart:math';

import 'package:magstep_dart/hr/hr_sample.dart';

import 'hrr_model.dart';

/// Fits heart rate recovery (HRR) curves.
///
/// This implementation avoids heavy numerical solvers and instead
/// applies a log-linear least squares approach:
///
///   ln(HR - c) = ln(a) - k * t
///
/// This is sufficient for clean physiological recovery signals
/// and works reliably on-device.
/// library hrr_fitter;

/// Fits an exponential HR recovery model from HR samples.
///
/// Parameters:
/// - [samples]: HR samples starting immediately after exercise stop
/// - [minC]: Minimum allowed asymptotic HR (prevents log instability)
///
/// Returns:
/// - A fitted [HrrModel], or null if fitting fails
HrrModel? fitHrrModel(List<HrSample> samples, {double minC = 40.0}) {
  if (samples.length < 5) return null;

  final times = <double>[];
  final values = <double>[];

  // Estimate asymptotic HR as the minimum observed value
  final double c = max(samples.map((s) => s.hr).reduce(min), minC);

  for (final s in samples) {
    final adjusted = s.hr - c;
    if (adjusted <= 0) continue;

    times.add(s.time - samples.first.time);
    values.add(log(adjusted));
  }

  if (times.length < 3) return null;

  // Linear regression: y = b + m*x
  double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
  final n = times.length;

  for (int i = 0; i < n; i++) {
    sumX += times[i];
    sumY += values[i];
    sumXY += times[i] * values[i];
    sumXX += times[i] * times[i];
  }

  final denominator = n * sumXX - sumX * sumX;
  if (denominator == 0) return null;

  final slope = (n * sumXY - sumX * sumY) / denominator;
  final intercept = (sumY - slope * sumX) / n;

  final a = exp(intercept);
  final k = -slope;

  if (k <= 0 || a.isNaN || k.isNaN) return null;

  return HrrModel(a: a, k: k, c: c);
}
