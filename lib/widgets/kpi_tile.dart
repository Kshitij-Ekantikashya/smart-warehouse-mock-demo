// lib/widgets/kpi_tile.dart

import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// KPI tile widget with customizable background and text color.
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alert;
  final Color? backgroundColor;
  final Color? valueColor;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
    this.backgroundColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (alert ? AppColors.accent : AppColors.primary);
    final valColor = valueColor ?? AppColors.text;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.text),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.text.withAlpha(200),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
