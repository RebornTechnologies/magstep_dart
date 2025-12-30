import 'butterworth.dart';
import 'dsp_result.dart';
import 'filtfilt.dart';
import 'sos_filter.dart';

/// Supported DSP filter types
enum DspFilterType { lowPass, highPass, bandPass }

/// Reusable DSP filter for IMU + physiological signals.
///
/// Design goals:
/// - SciPy-equivalent Butterworth filters
/// - SOS (biquad) stability
/// - Zero-phase filtfilt
/// - Shared across accel, gyro, HR
class DspFilter {
  final SosFilter _sos;

  DspFilter._(this._sos);

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Low-pass Butterworth (e.g. HR smoothing)
  factory DspFilter.lowPass({
    required double cutoffHz,
    required double fsHz,
    int order = 2,
  }) {
    return DspFilter._(
      SosFilter(
        Butterworth.lowpassSos(order: order, cutoffHz: cutoffHz, fsHz: fsHz),
      ),
    );
  }

  /// High-pass Butterworth (e.g. gyro drift removal)
  factory DspFilter.highPass({
    required double cutoffHz,
    required double fsHz,
    int order = 2,
  }) {
    return DspFilter._(
      SosFilter(
        Butterworth.highpassSos(order: order, cutoffHz: cutoffHz, fsHz: fsHz),
      ),
    );
  }

  /// Band-pass Butterworth (e.g. step detection)
  factory DspFilter.bandPass({
    required double lowHz,
    required double highHz,
    required double fsHz,
    int order = 2,
  }) {
    return DspFilter._(
      SosFilter(
        Butterworth.bandpassSos(
          order: order,
          lowHz: lowHz,
          highHz: highHz,
          fsHz: fsHz,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Processing
  // ---------------------------------------------------------------------------

  /// Applies zero-phase Butterworth filtering to 3-axis data.
  ///
  /// Axis arrays MUST have equal length.
  DspResult apply({
    required List<double> x,
    required List<double> y,
    required List<double> z,
  }) {
    assert(x.length == y.length && y.length == z.length);

    return DspResult(
      x: FiltFilt.apply(x, _sos),
      y: FiltFilt.apply(y, _sos),
      z: FiltFilt.apply(z, _sos),
    );
  }
}
