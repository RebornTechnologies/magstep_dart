import 'detect_extrema.dart';

class ExtremumPair {
  final Extremum first;
  final Extremum second;

  ExtremumPair({required this.first, required this.second});

  double get amplitude => (second.value - first.value).abs();

  int get indexDistance => (second.index - first.index).abs();
}

class PairExtrema {
  /// Pairs extrema into candidate motion cycles.
  ///
  /// Rules:
  /// - extrema must be consecutive
  /// - types must be MIN → MAX or MAX → MIN
  /// - amplitude must exceed threshold
  /// - index distance must exceed threshold
  static List<ExtremumPair> pairExtrema(
    List<Extremum> extrema, {
    double minAmplitude = 0.2,
    int minIndexDistance = 3,
  }) {
    final pairs = <ExtremumPair>[];

    if (extrema.length < 2) {
      return pairs;
    }

    for (int i = 0; i < extrema.length - 1; i++) {
      final a = extrema[i];
      final b = extrema[i + 1];

      // Rule 1: must be opposite types
      if (a.type == b.type) {
        continue;
      }

      final pair = ExtremumPair(first: a, second: b);

      // Rule 2: amplitude threshold
      if (pair.amplitude < minAmplitude) {
        continue;
      }

      // Rule 3: index distance threshold
      if (pair.indexDistance < minIndexDistance) {
        continue;
      }

      pairs.add(pair);
    }

    return pairs;
  }
}
