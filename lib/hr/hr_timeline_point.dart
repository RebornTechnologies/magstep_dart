import 'hr_sample.dart';

/// One point in the HR timeline used for visualization,

class HrTimelinePoint {
  /// Time since session start (seconds)
  final double timeSeconds;

  /// Heart-rate sample at this time
  final HrSample sample;

  /// Heart-rate zone (Edwards model)
  ///
  /// Values:
  /// -1 → below zone 1
  ///  1 → zone 1 (50–60%)
  ///  2 → zone 2 (60–70%)
  ///  3 → zone 3 (70–80%)
  ///  4 → zone 4 (80–90%)
  ///  5 → zone 5 (90–100%+)
  final int zone;

  /// Incremental Banister TRIMP contribution at this second
  final double trimp;

  /// Dynamic HRmax value at this time step
  ///
  /// This may increase over time if higher sustained HR is detected.
  final double hrMax;

  const HrTimelinePoint({
    required this.timeSeconds,
    required this.sample,
    required this.zone,
    required this.trimp,
    required this.hrMax,
  });
}
