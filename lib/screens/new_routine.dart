import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/screens/exercise_selector.dart';

class CreateRoutinePage extends StatelessWidget {
  const CreateRoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<RoutineProvider>().initializeCreation();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _saveRoutine(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
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

  Widget _buildExercisesList(BuildContext context) {
    final List<RoutineExercise> exercises = context
        .watch<RoutineProvider>()
        .creationExercises;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
      onReorder: (int oldIndex, int newIndex) {
        context.read<RoutineProvider>().reorderExercises(oldIndex, newIndex);
      },
      itemBuilder: (BuildContext context, int index) {
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
          children: <Widget>[
            Row(
              children: <Widget>[
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
              children: <Widget>[
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
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Future<void> _showAddExerciseDialog(BuildContext context) async {
    final Exercise? selectedExercise = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const ExerciseSelectionPage(),
      ),
    );

    if (selectedExercise != null) {
      print('Selected: ${selectedExercise.name}');
    }
  }

  void _showEditExerciseDialog(
    BuildContext context,
    int index,
    RoutineExercise exercise,
  ) {
    final TextEditingController setsController = TextEditingController(
      text: '${exercise.sets ?? 3}',
    );
    final TextEditingController repsController = TextEditingController(
      text: '${exercise.reps ?? 10}',
    );
    final TextEditingController restController = TextEditingController(
      text: '${exercise.restSeconds ?? 60}',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
        actions: <Widget>[
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

  void _saveRoutine(BuildContext context) async {}
}
