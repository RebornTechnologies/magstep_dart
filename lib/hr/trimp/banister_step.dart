import 'dart:math';
import 'banister_constants.dart';

/// Computes the Banister TRIMP contribution for a single HR sample.
///
/// Notes:
/// - Assumes dt = 1 second
/// - Returns already time-normalized value (÷60)
/// - HR values ≤ HRrest contribute zero load
double banisterTrimpAtSample({
  required double hr,
  required double hrRest,
  required double hrMax,
  required Sex sex,
}) {
  if (hr <= hrRest) return 0.0;

  final scale = banisterScale(sex);
  final exponent = banisterExponent(sex);

  final hrr = ((hr - hrRest) / (hrMax - hrRest)).clamp(0.0, 1.0);

  return (hrr * scale * exp(exponent * hrr)) / 60.0;
}
