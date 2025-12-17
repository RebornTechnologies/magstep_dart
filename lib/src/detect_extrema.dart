class Extremum {
  final int index;
  final ExtremumType type;
  final double value;

  Extremum({required this.index, required this.type, required this.value});
}

enum ExtremumType { min, max }

class DetectExtrema {
  static List<Extremum> findExtrema(List<double> signal) {
    final extrema = <Extremum>[];

    if (signal.length < 3) {
      return extrema;
    }

    for (int i = 1; i < signal.length - 1; i++) {
      final prev = signal[i - 1];
      final curr = signal[i];
      final next = signal[i + 1];

      if (curr > prev && curr > next) {
        extrema.add(Extremum(index: i, type: ExtremumType.max, value: curr));
      } else if (curr < prev && curr < next) {
        extrema.add(Extremum(index: i, type: ExtremumType.min, value: curr));
      }
    }

    return extrema;
  }
}
