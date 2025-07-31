// lib/widgets/trend_line_chart.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/reading_provider.dart';
import '../../theme/colors.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final readings = context.watch<ReadingProvider>().recentReadings;
    final recent = readings.take(60).toList().reversed.toList();

    List<FlSpot> tempData = [];
    List<FlSpot> humidData = [];
    List<FlSpot> gasData = [];

    double maxYValue = 0;

    for (int i = 0; i < recent.length; i++) {
      final temp = recent[i].temperature.toDouble();
      final humid = recent[i].humidity.toDouble();
      final gas = recent[i].gas.toDouble();

      tempData.add(FlSpot(i.toDouble(), temp));
      humidData.add(FlSpot(i.toDouble(), humid));
      gasData.add(FlSpot(i.toDouble(), gas));

      maxYValue = [maxYValue, temp, humid, gas].reduce((a, b) => a > b ? a : b);
    }

    final adjustedMaxY = ((maxYValue + 10) / 10).ceil() * 10.0;

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              "Environmental Trends",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 270,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 60,
                  minY: 0,
                  maxY: adjustedMaxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    verticalInterval: 10,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.grey.shade800, strokeWidth: 0.5),
                    getDrawingVerticalLine: (_) =>
                        FlLine(color: Colors.grey.shade800, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 15,
                        getTitlesWidget: (value, _) => Text(
                          "-${(60 - value).toInt()}s",
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  lineBarsData: [
                    _buildLine(tempData, Colors.orange),
                    _buildLine(humidData, Colors.cyan),
                    _buildLine(gasData, Colors.purple),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a smooth line for a given sensor data type
  LineChartBarData _buildLine(List<FlSpot> data, Color color) {
    return LineChartBarData(
      spots: data,
      isCurved: true,
      barWidth: 2.5,
      color: color,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: false),
    );
  }
}
