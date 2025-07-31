// File: lib/models/reading.dart

class Reading {
  final double temperature;   // Temperature in °C
  final double humidity;      // Humidity in %
  final double gas;           // Gas concentration in ppm
  final double space;         // Free space percentage (0–100%)
  final double stack;         // Stack fill percentage (0–100%)
  final double distSpace;     // Distance from ultrasonic sensor for space in cm
  final double distStack;     // Distance from ultrasonic sensor for stack in cm
  final DateTime timestamp;   // Timestamp of the reading
  final bool alarm;           // Alarm status (true if triggered)

  Reading({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.space,
    required this.stack,
    required this.distSpace,
    required this.distStack,
    required this.timestamp,
    required this.alarm,
  });

  // Returns an empty Reading with default values
  factory Reading.empty() {
    return Reading(
      temperature: 0.0,
      humidity: 0.0,
      gas: 0.0,
      space: 0.0,
      stack: 0.0,
      distSpace: 0.0,
      distStack: 0.0,
      timestamp: DateTime.now(),
      alarm: false,
    );
  }

  // Constructs a Reading object from JSON
  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      temperature: (json['temp'] ?? 0).toDouble(),
      humidity: (json['hum'] ?? 0).toDouble(),
      gas: (json['gas'] ?? 0).toDouble(),
      space: (json['space_pct'] ?? 0).toDouble(),
      stack: (json['stack_pct'] ?? 0).toDouble(),
      distSpace: (json['dist_space'] ?? -1).toDouble(),
      distStack: (json['dist_stack'] ?? -1).toDouble(),
      timestamp: DateTime.tryParse(json['ts'] ?? '') ?? DateTime.now(),
      alarm: json['alarm'].toString().toLowerCase() == 'true' || json['alarm'] == 1,
    );
  }

  // Converts a Reading object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': 'env',
      'ts': timestamp.toIso8601String(),
      'temp': temperature,
      'hum': humidity,
      'gas': gas,
      'dist_space': distSpace >= 0 ? distSpace : null,
      'dist_stack': distStack >= 0 ? distStack : null,
      'space_pct': space,
      'stack_pct': stack,
      'alarm': alarm,
    };
  }
}
