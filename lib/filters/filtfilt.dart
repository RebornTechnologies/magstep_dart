import 'dart:math';

/// ===============================
/// SciPy-compatible filtfilt
/// Gustafsson method
/// ===============================

List<double> scipyFiltfilt(List<double> x, List<double> b, List<double> a) {
  if (x.isEmpty) return [];

  final int ntaps = max(a.length, b.length);
  final int padLen = 3 * (ntaps - 1);

  if (x.length <= padLen) {
    throw ArgumentError('Input signal too short for filtfilt padding');
  }

  // -----------------------------
  // Step 1: Reflect padding
  // -----------------------------
  final List<double> front = List.generate(
    padLen,
    (i) => 2 * x.first - x[padLen - i],
  );

  final List<double> back = List.generate(
    padLen,
    (i) => 2 * x.last - x[x.length - 2 - i],
  );

  final List<double> padded = [...front, ...x, ...back];

  // -----------------------------
  // Step 2: Forward IIR filter
  // -----------------------------
  final forward = _lfilter(b, a, padded);

  // -----------------------------
  // Step 3: Reverse
  // -----------------------------
  final reversed = forward.reversed.toList();

  // -----------------------------
  // Step 4: Backward IIR filter
  // -----------------------------
  final backward = _lfilter(b, a, reversed);

  // -----------------------------
  // Step 5: Reverse back
  // -----------------------------
  final y = backward.reversed.toList();

  // -----------------------------
  // Step 6: Remove padding
  // -----------------------------
  return y.sublist(padLen, padLen + x.length);
}

/// =================================
/// SciPy-style IIR lfilter
/// =================================
List<double> _lfilter(List<double> b, List<double> a, List<double> x) {
  final int n = x.length;
  final List<double> y = List.filled(n, 0.0);

  for (int i = 0; i < n; i++) {
    double acc = 0.0;

    // Numerator
    for (int j = 0; j < b.length; j++) {
      if (i - j >= 0) {
        acc += b[j] * x[i - j];
      }
    }

    // Denominator
    for (int j = 1; j < a.length; j++) {
      if (i - j >= 0) {
        acc -= a[j] * y[i - j];
      }
    }

    y[i] = acc / a[0];
  }

  return y;
}
