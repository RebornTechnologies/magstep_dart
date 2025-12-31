/// Tracks dynamic HRmax updates during a session.
///
/// HRmax is updated only when:
/// - A higher HR is observed
/// - The HR exceeds the current HRmax by at least [minDelta]
/// - The HR is sustained for [sustainSeconds]
///
/// This prevents noise, spikes, and sensor artifacts
/// from inflating HRmax.
class HrMaxTracker {
  /// Number of consecutive seconds HR must be sustained
  final int sustainSeconds;

  /// Minimum BPM increase required to consider a new HRmax
  final double minDelta;

  double _currentHrMax;
  double _candidateHr;
  int _candidateCount = 0;
  bool _updated = false;

  HrMaxTracker({
    required double initialHrMax,
    this.sustainSeconds = 5,
    this.minDelta = 2.0,
  }) : _currentHrMax = initialHrMax,
       _candidateHr = initialHrMax;

  /// Current accepted HRmax
  double get hrMax => _currentHrMax;

  /// Whether HRmax was updated at least once
  bool get hasUpdated => _updated;

  /// Updates HRmax tracker with a new HR sample.
  ///
  /// This method is designed to be called once per second.
  /// Returns the currently accepted HRmax.
  double update(double hr) {
    // HR must exceed current HRmax by a meaningful margin
    if (hr <= _currentHrMax + minDelta) {
      _resetCandidate();
      return _currentHrMax;
    }

    // Track sustained candidate HR
    if (hr == _candidateHr) {
      _candidateCount++;
    } else {
      _candidateHr = hr;
      _candidateCount = 1;
    }

    // Accept new HRmax if sustained long enough
    if (_candidateCount >= sustainSeconds) {
      _currentHrMax = _candidateHr;
      _updated = true;
      _resetCandidate();
    }

    return _currentHrMax;
  }

  void _resetCandidate() {
    _candidateHr = _currentHrMax;
    _candidateCount = 0;
  }
}
