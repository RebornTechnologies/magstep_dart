/// One Second-Order Section (SOS / biquad)
class Biquad {
  final double b0, b1, b2;
  final double a1, a2;

  double _x1 = 0, _x2 = 0;
  double _y1 = 0, _y2 = 0;

  Biquad(this.b0, this.b1, this.b2, this.a1, this.a2);

  double process(double x) {
    final y = b0 * x + b1 * _x1 + b2 * _x2 - a1 * _y1 - a2 * _y2;

    _x2 = _x1;
    _x1 = x;
    _y2 = _y1;
    _y1 = y;

    return y;
  }

  void reset() {
    _x1 = _x2 = _y1 = _y2 = 0;
  }
}
