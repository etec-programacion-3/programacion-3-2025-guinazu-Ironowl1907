import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SimpleBarChart extends StatefulWidget {
  const SimpleBarChart({super.key});

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  final Map<DateTime, int> dateIntSets = <DateTime, int>{
    DateTime(2025, 10, 27): 0,
    DateTime(2025, 10, 28): 1,
    DateTime(2025, 10, 29): 2,
    DateTime(2025, 10, 30): 3,
    DateTime(2025, 10, 31): 4,
    DateTime(2025, 11, 1): 5,
    DateTime(2025, 11, 2): 6,
    DateTime(2025, 11, 3): 7,
    DateTime(2025, 11, 4): 8,
    DateTime(2025, 11, 5): 9,
    DateTime(2025, 11, 6): 10,
    DateTime(2025, 11, 7): 11,
    DateTime(2025, 11, 8): 12,
  };

  int? selectectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          '$selectectedIndex',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              titlesData: buildFlTitleData(),
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
              barGroups: dateIntSets.entries.toList().asMap().entries.map((
                MapEntry<int, MapEntry<DateTime, int>> entry,
              ) {
                final int index = entry.key;
                final MapEntry<DateTime, int> data = entry.value;

                return BarChartGroupData(
                  x: data.key.day,
                  barRods: <BarChartRodData>[
                    BarChartRodData(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      width: 20,
                      toY: data.value.toDouble(),
                      color: selectectedIndex == index
                          ? Theme.of(context)
                                .colorScheme
                                .secondary // Highlighted color
                          : Theme.of(
                              context,
                            ).colorScheme.primary, // Normal color
                    ),
                  ],
                );
              }).toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (_, int index1, _, _) {
                    return null;
                  },
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                touchCallback:
                    (FlTouchEvent event, BarTouchResponse? response) {
                      if (event is FlTapUpEvent &&
                          response != null &&
                          response.spot != null) {
                        setState(() {
                          selectectedIndex =
                              response.spot!.touchedBarGroupIndex;
                        });
                      }
                    },
              ),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData? buildFlTitleData() {
    return const FlTitlesData(
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
