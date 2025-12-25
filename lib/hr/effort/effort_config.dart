/// Configuration parameters for effort detection.
///
/// These thresholds should be conservative by default
/// to avoid false positives caused by HR noise.
class EffortDetectionConfig {
  /// HR percentage of HRmax to start an effort
  /// Typical values: 0.70–0.80
  final double startThresholdPct;

  /// HR percentage of HRmax to end an effort
  /// Should be lower than startThresholdPct
  final double endThresholdPct;

  /// Minimum duration (seconds) to consider a valid effort
  final double minEffortDuration;

  /// Minimum recovery time (seconds) before detecting a new effort
  final double minRecoveryDuration;

  const EffortDetectionConfig({
    this.startThresholdPct = 0.75,
    this.endThresholdPct = 0.65,
    this.minEffortDuration = 30,
    this.minRecoveryDuration = 20,
  });
}
