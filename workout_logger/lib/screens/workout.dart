import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/screens/routine_page.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/screens/newRoutine.dart';
import 'package:workout_logger/screens/routine_details.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Future<List<Routine>> _routinesFuture;

  @override
  void initState() {
    super.initState();
    _routinesFuture = DatabaseService.instance.getAllRoutines();
  }

  // Method to refresh routines
  void _refreshRoutines() {
    setState(() {
      _routinesFuture = DatabaseService.instance.getAllRoutines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Start",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            MenuButton(
              label: "Free Form",
              icon: const Icon(Icons.add, size: 28),
              onPressed: () {
                print("Free Form page button");
              },
            ),
            const SizedBox(height: 24),
            Text(
              "From Routine",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // FutureBuilder for routines
            FutureBuilder<List<Routine>>(
              future: _routinesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error loading routines",
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshRoutines,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final routines = snapshot.data ?? [];

                if (routines.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No routines found",
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create your first workout routine to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: routines.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return routineCard(
                      routine,
                      index,
                      colorScheme,
                      _refreshRoutines,
                      onRoutineSelected: () => _onRoutineSelected(routine),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onRoutineSelected(Routine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoutineDetailsPage(routine: routine),
      ),
    );
  }
}

// Detailed routine card from the second document, modified for workout context
Widget routineCard(
  Routine routine,
  int index,
  ColorScheme colorScheme,
  Function() refreshRoutines, {
  VoidCallback? onRoutineSelected,
}) {
  return FutureBuilder<List<DetailedRoutineExercise>>(
    future: DatabaseService.instance.getDetailedRoutineExercisesByRoutine(
      routine.id!,
    ),
    builder: (context, snapshot) {
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

      final exercises = snapshot.data ?? [];

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.primaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              onRoutineSelected ??
              () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (context) => RoutineDetailsPage(routine: routine),
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Routine name + menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        routine.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () =>
                          _showRoutineMenu(routine, context, refreshRoutines),
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),

                /// Routine description
                if (routine.description != null &&
                    routine.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    routine.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                /// Exercises count + placeholder duration
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${exercises.length} exercises",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "~45 min", // TODO: calculate dynamically
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Exercises preview
                Text(
                  "Exercises:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                if (exercises.isEmpty)
                  Text(
                    "No exercises added yet",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.5),
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
}

Column listExercises(
  List<DetailedRoutineExercise> exercises,
  ColorScheme colorScheme,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...exercises
          .take(3)
          .map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
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
            "+${exercises.length - 3} more exercises",
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

void _showRoutineMenu(
  Routine routine,
  BuildContext context,
  Function() refreshRoutines,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (context) => CreateRoutinePage(routine: routine),
                ),
              );

              if (result == true) {
                refreshRoutines();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate Routine'),
            onTap: () {
              Navigator.pop(context);
              duplicateRoutine(routine, context, refreshRoutines);
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

Future<void> duplicateRoutine(
  Routine routine,
  BuildContext context,
  Function() refreshRoutines,
) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final originalRoutineExercises = await DatabaseService.instance
        .getRoutineExercisesByRoutine(routine.id!);

    final duplicatedRoutine = Routine(
      name: "Copy of ${routine.name}",
      description: routine.description,
    );

    final newRoutineId = await DatabaseService.instance.createRoutine(
      duplicatedRoutine,
    );

    for (final routineExercise in originalRoutineExercises) {
      final newRoutineExercise = RoutineExercise(
        routineId: newRoutineId,
        exerciseId: routineExercise.exerciseId,
        sets: routineExercise.sets,
        order: routineExercise.order,
        reps: routineExercise.reps,
        restSeconds: routineExercise.restSeconds,
      );

      await DatabaseService.instance.createRoutineExercise(newRoutineExercise);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

    refreshRoutines();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Routine "${routine.name}" duplicated successfully'),
          action: SnackBarAction(
            label: 'Edit',
            onPressed: () async {
              final newRoutine = Routine(
                id: newRoutineId,
                name: duplicatedRoutine.name,
                description: duplicatedRoutine.description,
              );

              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (context) => CreateRoutinePage(routine: newRoutine),
                ),
              );

              if (result == true) {
                refreshRoutines();
              }
            },
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error duplicating routine: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void showDeleteConfirmation(Routine routine, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Routine'),
      content: Text(
        'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            DatabaseService.instance.deleteRoutine(routine.id!);
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

class MenuButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed ?? () => print(label),
        icon: icon,
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

PreferredSizeWidget workoutAppBar() {
  return AppBar(
    title: const Text("Workout"),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Builder(
        builder: (context) {
          final dividerColor = Theme.of(context).dividerColor;
          return Container(color: dividerColor, height: 1.0);
        },
      ),
    ),
  );
}
