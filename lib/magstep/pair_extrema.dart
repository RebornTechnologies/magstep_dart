/// Pairs minima and maxima into ordered (min, max) extrema pairs.
/// Direct port of `pair_extrema.py`.
///
/// Each pair represents a candidate step shape.
List<List<int>> pairExtrema(List<int> maxima, List<int> minima) {
  if (maxima.isEmpty || minima.isEmpty) {
    return <List<int>>[];
  }

  final List<List<int>> pairs = [];

  int i = 0;
  int j = 0;

  while (i < maxima.length && j < minima.length) {
    if (minima[j] < maxima[i]) {
      pairs.add([minima[j], maxima[i]]);
      j += 1;
      i += 1;
    } else {
      i += 1;
    }
  }

  return pairs;
}
