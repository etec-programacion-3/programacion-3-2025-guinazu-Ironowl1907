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
    final TypeFilter currentFilter = context
        .watch<ExerciseDetailsProvider>()
        .typeFilter;

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TypeFilter.heaviestWeight
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TypeFilter.heaviestWeight
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Heaviest Weight'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.totalReps;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TypeFilter.totalReps
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TypeFilter.totalReps
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Total Reps'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.totalVolume;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TypeFilter.totalVolume
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TypeFilter.totalVolume
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Total Volume'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().typeFilter =
                      TypeFilter.bestSetVolume;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TypeFilter.bestSetVolume
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TypeFilter.bestSetVolume
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Best Set Volume'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card timeSelector(BuildContext context) {
    final TimeFilter currentFilter = context
        .watch<ExerciseDetailsProvider>()
        .timeFilter;

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TimeFilter.week
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TimeFilter.week
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Week'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.month;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TimeFilter.month
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TimeFilter.month
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Month'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.months3;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TimeFilter.months3
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TimeFilter.months3
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Last 3 Months'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.year;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TimeFilter.year
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TimeFilter.year
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
                child: const Text('Year'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<ExerciseDetailsProvider>().timeFilter =
                      TimeFilter.all;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentFilter == TimeFilter.all
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  foregroundColor: currentFilter == TimeFilter.all
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
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
