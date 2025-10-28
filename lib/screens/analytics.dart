import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SimpleBarChart extends StatelessWidget {
  SimpleBarChart({super.key});

  final Map<DateTime, int> dateIntSets = <DateTime, int>{
    DateTime(2025, 10, 27): 0,
    DateTime(2025, 10, 28): 1,
    DateTime(2025, 10, 29): 4,
    DateTime(2025, 10, 30): 0,
    DateTime(2025, 10, 31): 2,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          titlesData: buildFlTitleData(),
          borderData: FlBorderData(
            show: true,
            border: const Border(top: BorderSide.none, right: BorderSide.none),
          ),
          gridData: const FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
          ),
          barGroups: dateIntSets.entries.map((MapEntry<DateTime, int> data) {
            return BarChartGroupData(
              x: data.key.day,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: data.value.toDouble(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (_, _, _, _) => null,
              getTooltipColor: (_) =>
                  Theme.of(context).colorScheme.primaryContainer,
            ),
            touchCallback: (FlTouchEvent event, BarTouchResponse? response) {},
          ),
        ),
      ),
    );
  }

  FlTitlesData? buildFlTitleData() {
    return const FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
