import 'biquad.dart';

/// Cascaded SOS filter (SciPy-equivalent)
class SosFilter {
  final List<Biquad> _sections;

  SosFilter(List<List<double>> sos)
    : _sections = sos.map((s) {
        return Biquad(
          s[0],
          s[1],
          s[2], // b0 b1 b2
          s[4],
          s[5], // a1 a2 (a0 is always 1)
        );
      }).toList();

  List<double> filter(List<double> input) {
    var output = List<double>.from(input);

    for (final section in _sections) {
      section.reset();
      for (var i = 0; i < output.length; i++) {
        output[i] = section.process(output[i]);
      }
    }
    return output;
  }
}
