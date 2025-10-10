import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/screens/routine_create_page.dart';

Widget routineCard(Routine routine, ColorScheme colorScheme) {
  return Consumer<RoutineProvider>(
    builder:
        (BuildContext context, RoutineProvider routineProvider, Widget? child) {
          return FutureBuilder<List<DetailedRoutineExercise>>(
            future: routineProvider.getDetailedRoutineExercisesByRoutine(
              routine.id!,
            ),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<DetailedRoutineExercise>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final List<DetailedRoutineExercise> exercises =
                      snapshot.data ?? <DetailedRoutineExercise>[];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: colorScheme.surfaceContainerLow,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (BuildContext context) =>
                                RoutineCreatorPage(currentRoutine: routine),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // --- Routine name + menu ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    routine.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () =>
                                      _showRoutineMenu(routine, context),
                                  color: colorScheme.onSurface,
                                ),
                              ],
                            ),

                            // --- Description ---
                            if (routine.description != null &&
                                routine.description!.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              Text(
                                routine.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // --- Exercises preview ---
                            Text(
                              'Exercises:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (exercises.isEmpty)
                              Text(
                                'No exercises added yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              listExercises(exercises, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  );
                },
          );
        },
  );
}

Column listExercises(
  List<DetailedRoutineExercise> exercises,
  ColorScheme colorScheme,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      ...exercises
          .take(3)
          .map(
            (DetailedRoutineExercise exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    exercise.exercise.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      if (exercises.length > 3)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '+${exercises.length - 3} more exercises',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onPrimaryContainer.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ],
  );
}

void _showRoutineMenu(Routine routine, BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Start Workout'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to workout session page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Start workout functionality'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Routine'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (BuildContext context) => const Placeholder(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate Routine'),
            onTap: () {
              Navigator.pop(context);
              // duplicateRoutine(
              //   routine,
              //   context,
              // ); // Call the new duplicate method
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Routine'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share routine functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Share routine functionality'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Routine',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              showDeleteConfirmation(routine, context);
            },
          ),
        ],
      ),
    ),
  );
}

void showDeleteConfirmation(Routine routine, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Delete Routine'),
      content: Text(
        'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<RoutineProvider>().delete(routine);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('${routine.name} deleted')));
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
