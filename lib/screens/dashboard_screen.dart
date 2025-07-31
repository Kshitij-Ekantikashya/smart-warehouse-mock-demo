// File: lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/reading_provider.dart';
import '../widgets/kpi_tile.dart';
import '../widgets/system_status_tiles.dart';
import '../widgets/stack_space_donut.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/rfid_log_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _dialogShowing = false;

  // For alert pop-up logic:
  DateTime? _lastAlertTimestamp;
  bool _tempWasBreached = false, _humidityWasBreached = false, _gasWasBreached = false;
  final int alertCooldownSeconds = 20;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Alert logic: show on new breach only, at most one at a time, with cooldown. Null-safety assured!
  void _checkAndShowAlert(
    BuildContext context, {
    required bool tempBreached,
    required bool humidityBreached,
    required bool gasBreached,
    required Map<String, double> thresholds,
    required double temp,
    required double hum,
    required double gas,
  }) {
    final now = DateTime.now();

    String? reason;

    if (tempBreached && !_tempWasBreached) {
      if (_lastAlertTimestamp == null ||
          now.difference(_lastAlertTimestamp!).inSeconds > alertCooldownSeconds) {
        reason =
            "Temperature is ABOVE threshold!\n\nCurrent: ${temp.toStringAsFixed(1)}°C\nThreshold: ${thresholds['temperature']}°C";
        _lastAlertTimestamp = now;
      }
    } else if (humidityBreached && !_humidityWasBreached) {
      if (_lastAlertTimestamp == null ||
          now.difference(_lastAlertTimestamp!).inSeconds > alertCooldownSeconds) {
        reason =
            "Humidity is ABOVE threshold!\n\nCurrent: ${hum.toStringAsFixed(1)}%\nThreshold: ${thresholds['humidity']}%";
        _lastAlertTimestamp = now;
      }
    } else if (gasBreached && !_gasWasBreached) {
      if (_lastAlertTimestamp == null ||
          now.difference(_lastAlertTimestamp!).inSeconds > alertCooldownSeconds) {
        reason =
            "Gas level is ABOVE threshold!\n\nCurrent: ${gas.toStringAsFixed(1)} ppm\nThreshold: ${thresholds['gas']} ppm";
        _lastAlertTimestamp = now;
      }
    }

    // Remember previous state for next tick
    _tempWasBreached = tempBreached;
    _humidityWasBreached = humidityBreached;
    _gasWasBreached = gasBreached;

    // Only show dialog if a non-null reason is set
    if (reason != null && !_dialogShowing) {
      _dialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.red.shade900,
          title: const Text(
            "Warehouse ALERT",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            reason!, // Null safety is guaranteed by the check above
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _dialogShowing = false;
                Navigator.of(ctx).pop();
              },
              child: const Text("Dismiss", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ReadingProvider>().latestReading;
    final thresholds = context.watch<ReadingProvider>().thresholds;

    final tempAlert = reading.temperature > (thresholds['temperature'] ?? double.infinity);
    final humidityAlert = reading.humidity > (thresholds['humidity'] ?? double.infinity);
    final gasAlert = reading.gas > (thresholds['gas'] ?? double.infinity);

    // Only fire alert pop-up if appropriate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAndShowAlert(
        context,
        tempBreached: tempAlert,
        humidityBreached: humidityAlert,
        gasBreached: gasAlert,
        thresholds: thresholds,
        temp: reading.temperature,
        hum: reading.humidity,
        gas: reading.gas,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Warehouse Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Environment KPIs
            Row(
              children: [
                Expanded(
                  child: KpiTile(
                    label: "Temperature",
                    value: "${reading.temperature.toStringAsFixed(1)}°C",
                    icon: Icons.thermostat,
                    alert: tempAlert,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiTile(
                    label: "Humidity",
                    value: "${reading.humidity.toStringAsFixed(1)}%",
                    icon: Icons.water_drop,
                    alert: humidityAlert,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiTile(
                    label: "Gas",
                    value: "${reading.gas.toStringAsFixed(1)} ppm",
                    icon: Icons.cloud,
                    alert: gasAlert,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // System Info
            const SystemStatusTiles(),
            const SizedBox(height: 24),

            // Stack usage and trend chart
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: StackSpaceDonut(reading: reading)),
                const SizedBox(width: 24),
                const Expanded(flex: 6, child: TrendLineChart()),
              ],
            ),
            const SizedBox(height: 24),

            // RFID log entries
            const RfidLogTable(),
            const SizedBox(height: 24),

            // Placeholder
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "Remaining Phase 2 widgets (buzzer, whitelist, etc.) will appear here.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
