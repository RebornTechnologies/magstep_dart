import 'filters/butterworth.dart';
import 'filters/filtfilt.dart';
import 'motionless_mask.dart';

class SignalSample {
  final double value;
  final DateTime timestamp;

  SignalSample({required this.value, required this.timestamp});
}

class SignalAnalysisResult {
  final List<double> filtered;
  final List<bool> motionless;

  SignalAnalysisResult({required this.filtered, required this.motionless});
}

class SignalAnalysis {
  static SignalAnalysisResult process(
    List<SignalSample> samples,
    ButterworthFilter filter,
  ) {
    final values = samples.map((s) => s.value).toList();

    final motionless = MotionlessMask.detectMotionless(values);
    final filtered = filtfilt(values, filter.b, filter.a);

    return SignalAnalysisResult(filtered: filtered, motionless: motionless);
  }
}
