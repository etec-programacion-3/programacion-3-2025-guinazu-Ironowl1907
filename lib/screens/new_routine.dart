import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';

class CreateRoutinePage extends StatelessWidget {
  final Routine? routine;

  const CreateRoutinePage({super.key, this.routine});

  @override
  Widget build(BuildContext context) {
    // Initialize on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().initializeCreation(routine: routine);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(routine == null ? 'Create Routine' : 'Edit Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _saveRoutine(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRoutineInfoSection(context),
          const Divider(height: 1),
          Expanded(child: _buildExercisesList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Routine Name',
              border: OutlineInputBorder(),
            ),
            controller:
                TextEditingController(
                    text: context.watch<RoutineProvider>().routineName,
                  )
                  ..selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: context
                          .watch<RoutineProvider>()
                          .routineName
                          .length,
                    ),
                  ),
            onChanged: (value) {
              context.read<RoutineProvider>().setRoutineName(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            controller:
                TextEditingController(
                    text: context.watch<RoutineProvider>().routineDescription,
                  )
                  ..selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: context
                          .watch<RoutineProvider>()
                          .routineDescription
                          .length,
                    ),
                  ),
            onChanged: (value) {
              context.read<RoutineProvider>().setRoutineDescription(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    final exercises = context.watch<RoutineProvider>().creationExercises;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add exercises',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: exercises.length,
      onReorder: (oldIndex, newIndex) {
        context.read<RoutineProvider>().reorderExercises(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        return _buildExerciseCard(context, exercises[index], index);
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    RoutineExercise routineExercise,
    int index,
  ) {
    // You'll need to fetch the exercise details
    // For now, showing with exercise ID
    return Card(
      key: ValueKey(routineExercise.exerciseId),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exercise #${routineExercise.exerciseId}', // Replace with actual exercise name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () =>
                      _showEditExerciseDialog(context, index, routineExercise),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    context.read<RoutineProvider>().removeExerciseFromCreation(
                      index,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  Icons.repeat,
                  '${routineExercise.sets ?? 0} sets',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.fitness_center,
                  '${routineExercise.reps ?? 0} reps',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.timer,
                  '${routineExercise.restSeconds ?? 0}s rest',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    // You'll need to implement a dialog to select exercises
    // This is a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: const Text('Exercise selection dialog goes here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add selected exercise
              context.read<RoutineProvider>().addExerciseToCreation(
                1, // Replace with selected exercise ID
                sets: 3,
                reps: 10,
                restSeconds: 60,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(
    BuildContext context,
    int index,
    RoutineExercise exercise,
  ) {
    final setsController = TextEditingController(text: '${exercise.sets ?? 3}');
    final repsController = TextEditingController(
      text: '${exercise.reps ?? 10}',
    );
    final restController = TextEditingController(
      text: '${exercise.restSeconds ?? 60}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: restController,
              decoration: const InputDecoration(labelText: 'Rest (seconds)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RoutineProvider>().updateExerciseInCreation(
                index,
                sets: int.tryParse(setsController.text),
                reps: int.tryParse(repsController.text),
                restSeconds: int.tryParse(restController.text),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveRoutine(BuildContext context) async {
    final provider = context.read<RoutineProvider>();

    if (!provider.isCreationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a name and at least one exercise'),
        ),
      );
      return;
    }

    // Create the routine
    final newRoutine = Routine(
      id: routine?.id,
      name: provider.routineName,
      description: provider.routineDescription.isEmpty
          ? null
          : provider.routineDescription,
      createdAt: routine?.createdAt ?? DateTime.now(),
    );

    if (routine == null) {
      await provider.add(newRoutine);
    } else {
      await provider.update(newRoutine);
    }

    // Save exercises (you'll need to implement this in your repository)
    // For each exercise in creationExercises, save to database

    provider.clearCreation();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
