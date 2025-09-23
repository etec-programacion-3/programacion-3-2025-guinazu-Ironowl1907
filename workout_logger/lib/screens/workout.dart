import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/screens/newRoutine.dart';
import 'package:workout_logger/widgets/routine_card.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key, required this.updateCallback});

  final Function updateCallback;

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

  void _refreshRoutines() {
    setState(() {
      _routinesFuture = DatabaseService.instance.getAllRoutines();
    });
    print("Here");
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
                    return routineCard(routine, colorScheme, _refreshRoutines);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
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
