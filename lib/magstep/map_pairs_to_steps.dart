/// Maps extrema index pairs to step timestamps.
/// Direct port of `map_pairs_to_steps.py`.
///
/// Each step time is the midpoint between min and max extrema.
List<double> mapPairsToSteps(List<List<int>> pairs, List<double> t) {
  if (pairs.isEmpty) return <double>[];

  final List<double> steps = [];

  for (final pair in pairs) {
    final int iMin = pair[0];
    final int iMax = pair[1];

    steps.add(0.5 * (t[iMin] + t[iMax]));
  }

  return steps;
}
