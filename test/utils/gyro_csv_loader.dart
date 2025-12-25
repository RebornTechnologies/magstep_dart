// import 'dart:io';

// /// Raw gyroscope sample
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

// /// Loads gyroscope CSV with format:
// /// time,gx,gy,gz
// ///
// /// - time can be:
// ///   - milliseconds since start
// ///   - unix epoch milliseconds
// List<GyroscopeSample> loadGyroscopeCsv(String path) {
//   final file = File(path);

//   if (!file.existsSync()) {
//     throw Exception('Gyroscope CSV not found: $path');
//   }

//   final lines = file.readAsLinesSync();

//   final startIndex = lines.first.toLowerCase().contains('time') ? 1 : 0;

//   DateTime? baseTime;

//   return lines.skip(startIndex).where((l) => l.trim().isNotEmpty).map((line) {
//     final parts = line.split(',');

//     if (parts.length < 4) {
//       throw FormatException('Invalid gyroscope CSV line: $line');
//     }

//     final rawTime = parts[0].trim();
//     final gx = double.parse(parts[1].trim());
//     final gy = double.parse(parts[2].trim());
//     final gz = double.parse(parts[3].trim());

//     DateTime timestamp;

//     if (double.tryParse(rawTime) != null) {
//       final t = double.parse(rawTime);
//       baseTime ??= DateTime.fromMillisecondsSinceEpoch(0);
//       timestamp = baseTime!.add(Duration(milliseconds: t.round()));
//     } else {
//       timestamp = DateTime.parse(rawTime);
//     }

//     return GyroscopeSample(gx: gx, gy: gy, gz: gz, timestamp: timestamp);
//   }).toList();
// }
