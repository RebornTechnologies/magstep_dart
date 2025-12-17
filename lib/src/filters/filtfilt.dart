/// Apply an IIR filter once (forward direction)
List<double> _applyIIR(List<double> signal, List<double> b, List<double> a) {
  final output = List<double>.filled(signal.length, 0.0);

  for (int i = 0; i < signal.length; i++) {
    double acc = 0.0;

    // Numerator (b)
    for (int j = 0; j < b.length; j++) {
      final idx = i - j;
      if (idx >= 0) {
        acc += b[j] * signal[idx];
      }
    }

    // Denominator (a), skip a[0]
    for (int j = 1; j < a.length; j++) {
      final idx = i - j;
      if (idx >= 0) {
        acc -= a[j] * output[idx];
      }
    }

    output[i] = acc;
  }

  return output;
}

/// Zero-phase filtering (equivalent to scipy.signal.filtfilt)
List<double> filtfilt(List<double> signal, List<double> b, List<double> a) {
  if (signal.isEmpty) return signal;

  // Forward filter
  final forward = _applyIIR(signal, b, a);

  // Reverse
  final reversed = forward.reversed.toList(growable: false);

  // Backward filter
  final backward = _applyIIR(reversed, b, a);

  // Reverse back
  return backward.reversed.toList(growable: false);
}
