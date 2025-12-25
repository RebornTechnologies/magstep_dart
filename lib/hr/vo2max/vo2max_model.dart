/// Models and utilities related to VO₂max estimation.
///
/// VO₂max represents the maximum oxygen uptake and is a key
/// indicator of aerobic fitness.
///
/// This implementation uses heart-rate based estimation methods
/// suitable for field and consumer-device usage.
/// library vo2max_model;

/// Holds VO₂max estimation results.
class Vo2MaxResult {
  /// Estimated VO₂max value (ml/kg/min)
  final double vo2max;

  /// Estimated resting heart rate (BPM)
  final double hrRest;

  /// Maximum heart rate used for estimation (BPM)
  final double hrMax;

  const Vo2MaxResult({
    required this.vo2max,
    required this.hrRest,
    required this.hrMax,
  });
}
