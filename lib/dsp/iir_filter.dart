/// Applies an IIR filter defined by b/a coefficients.
///
/// Equivalent to scipy.signal.lfilter
class IIRFilter {
  static List<double> apply(List<double> b, List<double> a, List<double> x) {
    final y = List<double>.filled(x.length, 0.0);

    for (int i = 0; i < x.length; i++) {
      for (int j = 0; j < b.length; j++) {
        if (i - j >= 0) {
          y[i] += b[j] * x[i - j];
        }
      }
      for (int j = 1; j < a.length; j++) {
        if (i - j >= 0) {
          y[i] -= a[j] * y[i - j];
        }
      }
    }
    return y;
  }
}
