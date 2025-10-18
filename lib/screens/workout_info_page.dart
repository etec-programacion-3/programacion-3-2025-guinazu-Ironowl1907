import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';

class WorkoutInfoPage extends StatelessWidget {
  const WorkoutInfoPage({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Wokrout Detail')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(children: <Widget>[infoCard(theme)]),
      ),
    );
  }

  Card infoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(workout.title ?? 'Unamed', style: theme.textTheme.titleLarge),
            Text(
              workout.endedAt.toString(),
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),
            ),
            Row(
              spacing: 8,
              children: <Widget>[
                infoChip('Duration', 'this is info', theme),
                infoChip('Sets', 'this is info', theme),
                infoChip('Volume', 'this is info', theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoChip(String title, String info, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.labelMedium!.copyWith(color: Colors.grey),
        ),
        Text(info),
      ],
    );
  }
}
