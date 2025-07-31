import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../providers/reading_provider.dart';
import 'kpi_tile.dart';

class SystemStatusTiles extends StatefulWidget {
  const SystemStatusTiles({super.key});

  @override
  State<SystemStatusTiles> createState() => _SystemStatusTilesState();
}

class _SystemStatusTilesState extends State<SystemStatusTiles> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readingProvider = context.watch<ReadingProvider>();
    final isWifiOnline = readingProvider.isConnected;
    final isNodeMcuOnline = readingProvider.isNodeMcuConnected;

    final hour = _now.hour;
    final isNight = hour < 6 || hour >= 18;
    final ist = _now.toLocal().toString().substring(11, 19); // HH:mm:ss
    final icon = isNight ? Icons.nights_stay : Icons.wb_sunny;

    return Row(
      children: [
        Expanded(
          child: KpiTile(
            label: "Time (IST)",
            value: ist,
            icon: icon,
            alert: false,
            backgroundColor: isNight
                ? Colors.indigo.shade700
                : Colors.amber.shade800,
            valueColor: AppColors.text,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KpiTile(
            label: "WiFi",
            value: isWifiOnline ? "Online" : "Offline",
            icon: Icons.wifi,
            alert: !isWifiOnline,
            backgroundColor: const Color(0xFF6BA292),
            valueColor: AppColors.text,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KpiTile(
            label: "NodeMCU",
            value: isNodeMcuOnline ? "Connected" : "Disconnected",
            icon: Icons.memory,
            alert: !isNodeMcuOnline,
            backgroundColor: const Color(0xFF6BA292),
            valueColor: AppColors.text,
          ),
        ),
      ],
    );
  }
}
