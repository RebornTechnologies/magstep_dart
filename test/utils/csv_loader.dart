// import 'dart:io';

// /// Scalar signal (MagPath)
// List<double> loadScalarCsv(String path) {
//   final lines = File(path).readAsLinesSync();

//   return lines
//       .where((l) => l.trim().isNotEmpty)
//       .map((l) => double.parse(l.trim()))
//       .toList();
// }

// /// Accelerometer samples
// class AccelerometerSample {
//   final double ax;
//   final double ay;
//   final double az;
//   final DateTime timestamp;

//   AccelerometerSample({
//     required this.ax,
//     required this.ay,
//     required this.az,
//     required this.timestamp,
//   });
// }

// List<AccelerometerSample> loadAccelerometerCsv(String path) {
//   final lines = File(path).readAsLinesSync();

//   return lines.skip(1).map((line) {
//     final parts = line.split(',');

//     return AccelerometerSample(
//       ax: double.parse(parts[0]),
//       ay: double.parse(parts[1]),
//       az: double.parse(parts[2]),
//       timestamp: DateTime.parse(parts[3]), // ONLY here
//     );
//   }).toList();
// }

// /// Gyroscope samples
// class GyroscopeSample {
//   final double gx;
//   final double gy;
//   final double gz;
//   final DateTime timestamp;

//   GyroscopeSample({
//     required this.gx,
//     required this.gy,
//     required this.gz,
//     required this.timestamp,
//   });
// }

// List<GyroscopeSample> loadGyroscopeCsv(String path) {
//   final lines = File(path).readAsLinesSync();

//   return lines.skip(1).map((line) {
//     final parts = line.split(',');

//     return GyroscopeSample(
//       gx: double.parse(parts[0]),
//       gy: double.parse(parts[1]),
//       gz: double.parse(parts[2]),
//       timestamp: DateTime.parse(parts[3]), // ONLY here
//     );
//   }).toList();
// }

import 'dart:io';

class ScalarSample {
  final double value;
  ScalarSample(this.value);
}

class AccelerometerSample {
  final double ax, ay, az;
  AccelerometerSample(this.ax, this.ay, this.az);
}

class GyroscopeSample {
  final double gx, gy, gz;
  GyroscopeSample(this.gx, this.gy, this.gz);
}

/// -------- SCALAR (MagPath) --------
List<double> loadScalarCsv(String path) {
  final lines = File(path).readAsLinesSync();

  return lines
      .skip(1) // ✅ skip header
      .where((l) => l.trim().isNotEmpty)
      .map((line) {
        final parts = line.split(',');

        // If scalar-only CSV → value in column 0
        // If timestamp,value → value in column 1
        final value = parts.length == 1 ? parts[0] : parts.last;

        return double.parse(value);
      })
      .toList();
}

/// -------- ACCELEROMETER --------
List<AccelerometerSample> loadAccelerometerCsv(String path) {
  final lines = File(path).readAsLinesSync();

  return lines
      .skip(1) // 🔴 skip header
      .where((l) => l.trim().isNotEmpty)
      .map((line) {
        final p = line.split(',');

        return AccelerometerSample(
          double.parse(p[1]),
          double.parse(p[2]),
          double.parse(p[3]),
        );
      })
      .toList();
}

/// -------- GYROSCOPE --------
List<GyroscopeSample> loadGyroscopeCsv(String path) {
  final lines = File(path).readAsLinesSync();

  return lines
      .skip(1) // 🔴 skip header
      .where((l) => l.trim().isNotEmpty)
      .map((line) {
        final p = line.split(',');

        return GyroscopeSample(
          double.parse(p[1]),
          double.parse(p[2]),
          double.parse(p[3]),
        );
      })
      .toList();
}
