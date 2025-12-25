/// Represents a detected physical effort segment.
///
/// An effort segment corresponds to a continuous period
/// where heart rate remains above a defined intensity threshold.
///
/// These segments are used for:
/// - HR recovery (HRR) analysis
/// - Interval detection
/// - Session intensity breakdown
class EffortSegment {
  /// Time (seconds) when effort started
  final double startTime;

  /// Time (seconds) when effort ended
  final double endTime;

  /// Heart rate at effort start
  final double startHr;

  /// Heart rate at effort end
  final double endHr;

  const EffortSegment({
    required this.startTime,
    required this.endTime,
    required this.startHr,
    required this.endHr,
  });

  /// Duration of the effort in seconds
  double get duration => endTime - startTime;
}
