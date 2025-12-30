/// Generic multi-axis DSP output.
/// Used by accel, gyro, mag, etc.
class DspResult {
  final List<double> x;
  final List<double> y;
  final List<double> z;

  const DspResult({required this.x, required this.y, required this.z});

  int get length => x.length;
}
