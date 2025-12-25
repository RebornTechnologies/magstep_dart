import '../core/step_event.dart';

class MagPathResult {
  final List<double> filtered;
  final List<bool> motionlessMask;
  final List<StepEvent> steps;
  final double samplingRate;

  MagPathResult({
    required this.filtered,
    required this.motionlessMask,
    required this.steps,
    required this.samplingRate,
  });
}
