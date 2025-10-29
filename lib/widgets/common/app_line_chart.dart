import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppLineChart extends StatefulWidget {
  const AppLineChart({super.key});

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          '$selectedIndex',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              titlesData: buildFlTitleData()!,
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                ),
              ),
              gridData: const FlGridData(
                horizontalInterval: 1,
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: dateIntSets.entries.toList().asMap().entries.map((
                    MapEntry<int, MapEntry<DateTime, int>> entry,
                  ) {
                    final int index = entry.key;
                    final MapEntry<DateTime, int> data = entry.value;
                    return FlSpot(
                      data.key.day.toDouble(),
                      data.value.toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: selectedIndex == index ? 6 : 4,
                        color: selectedIndex == index
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        strokeWidth: selectedIndex == index ? 2 : 0,
                        strokeColor: selectedIndex == index
                            ? Theme.of(context).colorScheme.surface
                            : Colors.transparent,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) => null).toList();
                  },
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? response) {
                      if (event is FlTapUpEvent &&
                          response != null &&
                          response.lineBarSpots != null &&
                          response.lineBarSpots!.isNotEmpty) {
                        setState(() {
                          selectedIndex =
                              response.lineBarSpots!.first.spotIndex;
                        });
                      }
                    },
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  int? selectedIndex;

  final Map<DateTime, int> dateIntSets = <DateTime, int>{
    DateTime(2025, 10, 27): 0,
    DateTime(2025, 10, 28): 1,
    DateTime(2025, 10, 29): 2,
    DateTime(2025, 10, 30): 3,
    DateTime(2025, 10, 31): 1,
    // DateTime(2025, 11, 1): 5,
    // DateTime(2025, 11, 2): 6,
    // DateTime(2025, 11, 3): 7,
    // DateTime(2025, 11, 4): 8,
    // DateTime(2025, 11, 5): 9,
    // DateTime(2025, 11, 6): 10,
    // DateTime(2025, 11, 7): 11,
    // DateTime(2025, 11, 8): 12,
  };

  FlTitlesData? buildFlTitleData() {
    return const FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 25),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
