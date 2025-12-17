class SessionConfig {
  /// Sampling frequency in Hz (must match device or timestamps)
  final double samplingRate;

  /// Butterworth filter order (even number recommended)
  final int filterOrder;

  /// Low-pass cutoff frequency in Hz
  final double cutoffHz;

  const SessionConfig({
    required this.samplingRate,
    this.filterOrder = 4,
    this.cutoffHz = 3.0,
  });
}
