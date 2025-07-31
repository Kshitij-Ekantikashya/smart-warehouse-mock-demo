// File: lib/models/rfid_log.dart

class RfidLog {
  final String timestamp;   // Timestamp of the RFID event
  final String uid;         // Unique ID of the RFID tag
  final String item;        // Item associated with the RFID tag
  final String direction;   // Direction of movement (in/out)

  RfidLog({
    required this.timestamp,
    required this.uid,
    required this.item,
    required this.direction,
  });

  // Constructs an RfidLog object from JSON
  factory RfidLog.fromJson(Map<String, dynamic> json) {
    return RfidLog(
      timestamp: json['ts'],
      uid: json['uid'],
      item: json['item'] ?? 'Unknown',
      direction: json['direction'],
    );
  }
}
