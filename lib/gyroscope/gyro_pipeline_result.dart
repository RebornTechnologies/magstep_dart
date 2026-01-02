class GyroPipelineResult {
  final List<double> x;
  final List<double> y;
  final List<double> z;

  GyroPipelineResult({required this.x, required this.y, required this.z});
  int get length => x.length;
}
