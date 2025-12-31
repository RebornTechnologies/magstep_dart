/// Detects local maxima and minima in a 1D signal.
/// Direct port of `detect_extrema.py`.
///
/// Returns a Map with keys:
/// - 'maxima': indices of local maxima
/// - 'minima': indices of local minima
Map<String, List<int>> detectExtrema(List<double> y, {int minDist = 1}) {
  final int n = y.length;
  if (n == 0) {
    return {'maxima': <int>[], 'minima': <int>[]};
  }

  // First derivative
  final List<double> dy = List.filled(n - 1, 0.0);
  for (int i = 0; i < n - 1; i++) {
    dy[i] = y[i + 1] - y[i];
  }

  // Sign of derivative
  final List<int> s = List.filled(dy.length, 0);
  for (int i = 0; i < dy.length; i++) {
    s[i] = dy[i] > 0 ? 1 : (dy[i] < 0 ? -1 : 0);
  }

  final List<int> maxima = [];
  final List<int> minima = [];

  for (int i = 0; i < s.length - 1; i++) {
    if (s[i] > 0 && s[i + 1] <= 0) {
      maxima.add(i + 1);
    }
    if (s[i] < 0 && s[i + 1] >= 0) {
      minima.add(i + 1);
    }
  }

  return {
    'maxima': minDist > 1 ? _enforceMinDist(maxima, minDist) : maxima,
    'minima': minDist > 1 ? _enforceMinDist(minima, minDist) : minima,
  };
}

List<int> _enforceMinDist(List<int> idxs, int minDist) {
  if (idxs.isEmpty) return <int>[];

  final List<int> keep = [idxs.first];
  for (final i in idxs.skip(1)) {
    if (i - keep.last >= minDist) {
      keep.add(i);
    }
  }
  return keep;
}
