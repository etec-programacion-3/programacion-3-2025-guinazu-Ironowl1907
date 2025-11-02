import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_details_provider.dart';
import 'package:workout_logger/widgets/common/app_line_chart.dart';
import 'package:workout_logger/widgets/muscle_group_chip.dart';

class ExerciseDetailsPage extends StatefulWidget {
  const ExerciseDetailsPage({super.key, required this.exercise});
  final Exercise exercise;

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  final Map<DateTime, double> dateIntSets = <DateTime, double>{
    DateTime(2025, 10, 18): 10,
    DateTime(2025, 10, 19): 0,
    DateTime(2025, 10, 20): 0,
    DateTime(2025, 10, 21): 0,
    DateTime(2025, 10, 22): 0,
    DateTime(2025, 10, 23): 0,
    DateTime(2025, 10, 24): 0,
    DateTime(2025, 10, 25): 0,
    DateTime(2025, 10, 26): 0,
    DateTime(2025, 10, 27): 0,
    DateTime(2025, 10, 28): 1,
    DateTime(2025, 10, 29): 2,
    DateTime(2025, 10, 30): 3,
    DateTime(2025, 10, 31): 1,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[titleCard(context), charts(context)],
        ),
      ),
      appBar: AppBar(title: Text(widget.exercise.name)),
    );
  }

  Widget charts(BuildContext context) {
    final TypeFilter selectedFilter = TypeFilter.heaviestWeight;
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Consumer<ExerciseDetailsProvider>(
                  builder:
                      (
                        BuildContext context,
                        ExerciseDetailsProvider provider,
                        _,
                      ) {
                        if (provider.dataPoints == null) {
                          return const AppLineChart(data: <DateTime, double>{});
                        } else {
                          return AppLineChart(data: provider.dataPoints!);
                        }
                      },
                ),
              ],
            ),
          ),
        ),
        typeSelector(context),
        timeSelector(context),
      ],
    );
  }

  Card typeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.heaviestWeight;
                },
                child: const Text('Heaviest Weight'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.totalReps;
                },
                child: const Text('Total Reps'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.totalVolume;
                },
                child: const Text('Total Volume'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.bestSetVolume;
                },
                child: const Text('Best Set Volume'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card timeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.week;
                },
                child: const Text('Week'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.month;
                },
                child: const Text('Month'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.months3;
                },
                child: const Text('Last 3 Months'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.year;
                },
                child: const Text('Year'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.all;
                },
                child: const Text('All'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card titleCard(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.exercise.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 28),
              ),
              const SizedBox.square(dimension: 4),
              Text(
                'Muscle Groups',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.grey),
              ),
              const SizedBox.square(dimension: 8),
              muscleGroupChip(context, widget.exercise),
            ],
          ),
        ),
      ),
    );
  }
}
