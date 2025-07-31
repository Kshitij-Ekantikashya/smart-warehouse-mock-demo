import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityProvider with ChangeNotifier {
  bool _isWifiConnected = true;      // Indicates if Wi-Fi is connected
  bool _isNodeMcuConnected = true;   // Indicates if NodeMCU is reachable

  bool get isWifiConnected => _isWifiConnected;
  bool get isNodeMcuConnected => _isNodeMcuConnected;

  Timer? _timer;

  ConnectivityProvider() {
    _startMonitoring();
  }

  // Starts periodic monitoring of connectivity status
  void _startMonitoring() {
    _checkConnectivity();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );
  }

  // Checks Wi-Fi and NodeMCU connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isWifiConnected = connectivityResult != ConnectivityResult.none;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.148.211:3000/api/v1/warehouse/latest'),
      ).timeout(const Duration(seconds: 2));

      _isNodeMcuConnected = response.statusCode == 200;
    } catch (_) {
      _isNodeMcuConnected = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
