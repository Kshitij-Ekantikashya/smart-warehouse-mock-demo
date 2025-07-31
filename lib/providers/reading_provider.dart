import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reading.dart';
import '../models/rfid_log.dart';
import '../services/api_service.dart';

class ReadingProvider extends ChangeNotifier {
  final ApiService _api;
  Reading _latestReading = Reading.empty();
  Reading get latestReading => _latestReading;

  final List<Reading> _recentReadings = [];
  List<Reading> get recentReadings => _recentReadings;

  List<RfidLog> _recentRfidLogs = [];
  List<RfidLog> get recentRfidLogs => _recentRfidLogs;

  Map<String, double> _thresholds = {
    'temperature': 45.0,
    'humidity': 95.0,
    'gas': 650.0,
  };
  Map<String, double> get thresholds => _thresholds;

  Timer? _pollingTimer;
  DateTime _lastUpdated = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? _lastAlarmTs;
  DateTime? get lastAlarmTs => _lastAlarmTs;

  ReadingProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  void startPolling() {
    _pollingTimer?.cancel();
    _fetchAndNotify();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchAndNotify(),
    );
  }

  Future<void> _fetchAndNotify() async {
    try {
      final reading = await _api.fetchLatestReading();
      _latestReading = reading;
      _updateRecentReadings(reading);
      _lastUpdated = DateTime.now();

      if (reading.alarm == true) {
        if (_lastAlarmTs == null ||
            _lastAlarmTs!.toIso8601String() != reading.timestamp.toIso8601String()) {
          _lastAlarmTs = reading.timestamp;
          notifyListeners();
        }
      }

      final rfidLogs = await _api.fetchRecentRfidLogs();
      updateRecentRfidLogs(rfidLogs);
    } catch (e) {
      print('Error in _fetchAndNotify: $e');
    } finally {
      notifyListeners();
    }
  }

  void updateRecentRfidLogs(List<RfidLog> logs) {
    _recentRfidLogs = logs;
    notifyListeners();
  }

  void _updateRecentReadings(Reading reading) {
    _recentReadings.insert(0, reading);
    if (_recentReadings.length > 120) {
      _recentReadings.removeLast();
    }
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  bool get isNodeMcuConnected => DateTime.now().difference(_latestReading.timestamp).inSeconds < 5;
  bool get isConnected => DateTime.now().difference(_lastUpdated).inSeconds < 5;

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
