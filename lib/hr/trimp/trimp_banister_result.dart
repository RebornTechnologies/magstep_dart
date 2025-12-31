class TrimpBanisterResult {
  /// Total Banister TRIMP score
  final double trimp;

  /// Time (seconds) where HR > HRrest
  final double activeTimeSeconds;

  const TrimpBanisterResult({
    required this.trimp,
    required this.activeTimeSeconds,
  });

  double get activeTimeMinutes => activeTimeSeconds / 60.0;
}
