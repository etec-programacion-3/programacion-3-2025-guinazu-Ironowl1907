import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppLineChart extends StatefulWidget {
  const AppLineChart({super.key, required this.data});

  final Map<DateTime, double> data;

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Sort data by date
    final List<MapEntry<DateTime, double>> sortedEntries =
        widget.data.entries.toList()..sort(
          (MapEntry<DateTime, double> a, MapEntry<DateTime, double> b) =>
              a.key.compareTo(b.key),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          selectedIndex != null
              ? sortedEntries[selectedIndex!].value.toStringAsFixed(1)
              : 'Tap a point',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              titlesData: buildFlTitleData(sortedEntries),
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
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: sortedEntries.asMap().entries.map((
                    MapEntry<int, MapEntry<DateTime, double>> entry,
                  ) {
                    final int index = entry.key;
                    final MapEntry<DateTime, double> data = entry.value;
                    return FlSpot(index.toDouble(), data.value);
                  }).toList(),
                  isCurved: false,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter:
                        (
                          FlSpot spot,
                          double percent,
                          LineChartBarData barData,
                          int index,
                        ) {
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
                    return touchedSpots
                        .map((LineBarSpot spot) => null)
                        .toList();
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

  FlTitlesData buildFlTitleData(
    List<MapEntry<DateTime, double>> sortedEntries,
  ) {
    return FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 25),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.toInt();
            if (index < 0 || index >= sortedEntries.length) {
              return const Text('');
            }
            final DateTime date = sortedEntries[index].key;
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${date.day}/${date.month}',
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      ),
    );
  }
}
