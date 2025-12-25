/// Subtract mean from signal (exact NumPy behavior)
/// Equivalent to:
///     signal = signal - np.mean(signal)
List<double> centerSignal(List<double> signal) {
  if (signal.isEmpty) return signal;

  // Compute mean
  double sum = 0.0;
  for (final v in signal) {
    sum += v;
  }
  final mean = sum / signal.length;

  // Subtract mean
  return signal.map((v) => v - mean).toList(growable: false);
}
