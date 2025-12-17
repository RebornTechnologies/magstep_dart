import 'dart:io';

/// Raw accelerometer sample
class AccelerometerSample {
  final double ax;
  final double ay;
  final double az;
  final DateTime timestamp;

  AccelerometerSample({
    required this.ax,
    required this.ay,
    required this.az,
    required this.timestamp,
  });
}

/// Loads accelerometer CSV with format:
/// time,ax,ay,az
///
/// - time can be:
///   - milliseconds since start
///   - unix epoch milliseconds
List<AccelerometerSample> loadAccelerometerCsv(String path) {
  final file = File(path);

  if (!file.existsSync()) {
    throw Exception('Accelerometer CSV not found: $path');
  }

  final lines = file.readAsLinesSync();

  final startIndex = lines.first.toLowerCase().contains('time') ? 1 : 0;

  DateTime? baseTime;

  return lines.skip(startIndex).where((l) => l.trim().isNotEmpty).map((line) {
    final parts = line.split(',');

    if (parts.length < 4) {
      throw FormatException('Invalid accelerometer CSV line: $line');
    }

    final rawTime = parts[0].trim();
    final ax = double.parse(parts[1].trim());
    final ay = double.parse(parts[2].trim());
    final az = double.parse(parts[3].trim());

    DateTime timestamp;

    if (double.tryParse(rawTime) != null) {
      final t = double.parse(rawTime);
      baseTime ??= DateTime.fromMillisecondsSinceEpoch(0);
      timestamp = baseTime!.add(Duration(milliseconds: t.round()));
    } else {
      timestamp = DateTime.parse(rawTime);
    }

    return AccelerometerSample(ax: ax, ay: ay, az: az, timestamp: timestamp);
  }).toList();
}
