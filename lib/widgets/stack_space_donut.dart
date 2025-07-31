// lib/widgets/stack_space_donut.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/reading.dart';
import '../../theme/colors.dart';

class StackSpaceDonut extends StatelessWidget {
  final Reading reading;

  const StackSpaceDonut({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final double rawStack = reading.stack.clamp(0, 100);
    final double rawSpace = reading.space.clamp(0, 100);
    final double fallback = (rawStack + rawSpace) == 0 ? 1 : 0;

    final double stackPercent = rawStack + fallback;
    final double spacePercent = rawSpace;

    final bool stackTooHigh = stackPercent > 90;
    final bool distStackTooLow = reading.distStack < 3;
    final bool spaceTooLow = spacePercent < 20;
    final bool distSpaceTooLow = reading.distSpace < 5;

    const baseStyle = TextStyle(
      color: Color(0xFFEAE3C3),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    Color dynamicColor(bool condition) =>
        condition ? Colors.redAccent : baseStyle.color!;

    final double maxHeight = 18.0;
    final double maxDepth = 28.0;
    final double totalVolume = maxHeight * maxDepth;

    final double usedHeight = maxHeight - reading.distStack;
    final double usedDepth = maxDepth - reading.distSpace;
    final double usedVolume = usedHeight * usedDepth;

    final double storageUsedPct = (usedVolume / totalVolume) * 100;
    final double storageFreePct = 100 - storageUsedPct;

    return Container(
      width: 600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Stack vs Free Space",
            style: TextStyle(
              color: Color(0xFFEAE3C3),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 42,
                sectionsSpace: 1,
                sections: [
                  PieChartSectionData(
                    value: stackPercent,
                    color: Color(0xFF6BA292),
                    title: "${stackPercent.toStringAsFixed(0)}%",
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: spacePercent,
                    color: Color(0xFF9BB6A1),
                    title: "${spacePercent.toStringAsFixed(0)}%",
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Stack height used: ${(18 - reading.distStack).toStringAsFixed(1)} cm",
                    style: baseStyle.copyWith(
                      color: dynamicColor(distStackTooLow),
                    ),
                  ),
                  Text(
                    "Stack height left: ${reading.distStack.toStringAsFixed(1)} cm",
                    style: baseStyle.copyWith(
                      color: dynamicColor(distStackTooLow),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Floor space used: ${(28 - reading.distSpace).toStringAsFixed(1)} cm",
                    style: baseStyle.copyWith(
                      color: dynamicColor(distSpaceTooLow),
                    ),
                  ),
                  Text(
                    "Floor space left: ${reading.distSpace.toStringAsFixed(1)} cm",
                    style: baseStyle.copyWith(
                      color: dynamicColor(distSpaceTooLow),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Stack consumed: ${stackPercent.toStringAsFixed(0)}%",
                    style: baseStyle.copyWith(
                      color: dynamicColor(stackTooHigh),
                    ),
                  ),
                  Text(
                    "Floor space: ${spacePercent.toStringAsFixed(0)}%",
                    style: baseStyle.copyWith(
                      color: dynamicColor(spaceTooLow),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Storage free: ${storageFreePct.toStringAsFixed(0)}%",
                    style: baseStyle.copyWith(
                      color: dynamicColor(storageFreePct < 10),
                    ),
                  ),
                  Text(
                    "Storage used: ${storageUsedPct.toStringAsFixed(0)}%",
                    style: baseStyle.copyWith(
                      color: dynamicColor(storageUsedPct > 90),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
