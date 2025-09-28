import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/widgets/routine_card.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      body: Consumer<RoutineProvider>(
        builder:
            (
              BuildContext context,
              RoutineProvider muscleGroupProvider,
              Widget? child,
            ) {
              final List<Routine> routines = context
                  .watch<RoutineProvider>()
                  .routines;
              return ListView.builder(
                itemCount: routines.length,
                itemBuilder: (BuildContext context, int index) {
                  final Routine routine = routines[index];
                  return routineCard(routine, colorScheme);
                },
              );
            },
      ),
    );
  }
}
