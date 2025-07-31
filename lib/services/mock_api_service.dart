import 'dart:async';
import 'dart:math';
import 'api_service.dart';
import '../models/reading.dart';
import '../models/rfid_log.dart';

class MockApiService extends ApiService {
  final Random _random = Random();

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Always allow login in demo mode
  }

  @override
  Future<Reading> fetchLatestReading() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Reading(
      temperature: 35.0 + (_random.nextDouble() * 20),
      humidity: 60.0 + (_random.nextDouble() * 40),
      gas: 300.0 + (_random.nextDouble() * 300),
      space: 60.0 + (_random.nextDouble() * 35),
      stack: 30.0 + (_random.nextDouble() * 60),
      distSpace: 5.0 + (_random.nextDouble() * 20),
      distStack: 2.0 + (_random.nextDouble() * 16),
      timestamp: DateTime.now(),
      alarm: _random.nextDouble() < 0.1,
    );
  }

  @override
  Future<List<RfidLog>> fetchRecentRfidLogs({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    const items = [
      'Component Box A',
      'Tool Kit B',
      'Raw Material C',
      'Finished Good D',
    ];
    const directions = ['in', 'out'];
    return List.generate(limit, (index) {
      return RfidLog(
        timestamp: _formatDateTime(
          DateTime.now().subtract(Duration(minutes: index * 5)),
        ),
        uid: 'UID${1000 + _random.nextInt(9000)}',
        item: items[_random.nextInt(items.length)],
        direction: directions[_random.nextInt(directions.length)],
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}";
  }

  @override
  Future<bool> requestBuzzer() async => true;
}
