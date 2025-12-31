import 'dart:math';

/// Fuses multiple axis signals using inverse-noise weighting.
/// Direct port of `fuse_axes_weighted` from Python.
List<double> fuseAxesWeighted(
  List<List<double>> signals,
  List<double> noiseAbsDevs, {
  double eps = 1e-9,
}) {
  final int numAxes = signals.length;
  if (numAxes == 0) return <double>[];

  final int n = signals[0].length;

  // Compute weights: w = 1 / (noise + eps)
  final List<double> w = List.filled(numAxes, 0.0);
  double wSum = 0.0;

  for (int i = 0; i < numAxes; i++) {
    w[i] = 1.0 / (noiseAbsDevs[i] + eps);
    wSum += w[i];
  }

  // Normalize weights
  for (int i = 0; i < numAxes; i++) {
    w[i] /= wSum;
  }

  // Fused signal
  final List<double> fused = List.filled(n, 0.0);

  for (int t = 0; t < n; t++) {
    double acc = 0.0;
    for (int a = 0; a < numAxes; a++) {
      acc += signals[a][t] * w[a];
    }
    fused[t] = acc;
  }

  return fused;
}
