import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/models/models.dart';

class RoutineCreatorPage extends StatefulWidget {
  const RoutineCreatorPage({super.key});

  @override
  State<RoutineCreatorPage> createState() => _RoutineCreatorPageState();
}

class _RoutineCreatorPageState extends State<RoutineCreatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MuscleGroupProvider>(context, listen: false).load();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RoutineProvider routineProvider = context.read<RoutineProvider>();
      routineProvider.initializeCreation();
      _nameController.text = routineProvider.routineName;
      _descriptionController.text = routineProvider.routineDescription;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const AddExerciseBottomSheet(),
    );
  }

  void _showEditExerciseDialog(int index, RoutineExercise exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          EditExerciseDialog(index: index, exercise: exercise),
    );
  }

  Future<void> _saveRoutine() async {
    final RoutineProvider routineProvider = context.read<RoutineProvider>();

    if (!routineProvider.isCreationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a name and at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await routineProvider.saveCreation();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveRoutine,
            tooltip: 'Save Routine',
          ),
        ],
      ),
      body: Consumer<RoutineProvider>(
        builder:
            (
              BuildContext context,
              RoutineProvider routineProvider,
              Widget? child,
            ) {
              return Column(
                children: <Widget>[
                  // Routine Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Routine Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fitness_center),
                          ),
                          onChanged: (String value) {
                            routineProvider.setRoutineName(value);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                          onChanged: (String value) {
                            routineProvider.setRoutineDescription(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Exercise List Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Exercises (${routineProvider.creationExercises.length})',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        FilledButton.icon(
                          onPressed: _showAddExerciseDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                  ),

                  // Exercise List
                  exerciseList(routineProvider, context),
                ],
              );
            },
      ),
    );
  }

  Expanded exerciseList(RoutineProvider routineProvider, BuildContext context) {
    return Expanded(
      child: routineProvider.creationExercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: routineProvider.creationExercises.length,
              onReorder: (int oldIndex, int newIndex) {
                routineProvider.reorderExercises(oldIndex, newIndex);
              },
              itemBuilder: (BuildContext context, int index) {
                final RoutineExercise exercise =
                    routineProvider.creationExercises[index];
                return ExerciseCard(
                  key: ValueKey(exercise.exerciseId),
                  exercise: exercise,
                  index: index,
                  onEdit: () => _showEditExerciseDialog(index, exercise),
                  onDelete: () {
                    routineProvider.removeExerciseFromCreation(index);
                  },
                );
              },
            ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final RoutineExercise exercise;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: FutureBuilder<Exercise?>(
          future: _getExercise(context),
          builder: (BuildContext context, AsyncSnapshot<Exercise?> snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }
            return const Text('Loading...');
          },
        ),
        subtitle: Text(
          '${exercise.sets ?? 3} sets × ${exercise.reps ?? 10} reps • ${exercise.restSeconds ?? 60}s rest',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete Exercise'),
                    content: const Text(
                      'Are you sure you want to remove this exercise?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Future<Exercise?> _getExercise(BuildContext context) async {
    final List<Exercise> exercises = context.read<ExerciseProvider>().exercises;
    return exercises.firstWhere((Exercise e) => e.id == exercise.exerciseId);
  }
}

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key});

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExerciseProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ExerciseProvider>(
                builder:
                    (
                      BuildContext context,
                      ExerciseProvider exerciseProvider,
                      Widget? child,
                    ) {
                      final List<Exercise> exercises = exerciseProvider
                          .exercises
                          .where((Exercise exercise) {
                            return exercise.name.toLowerCase().contains(
                              _searchQuery,
                            );
                          })
                          .toList();

                      if (exercises.isEmpty) {
                        return Center(
                          child: Text(
                            'No exercises found',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: exercises.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Exercise exercise = exercises[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.fitness_center),
                            ),
                            title: Text(exercise.name),
                            subtitle: exercise.description != null
                                ? Text(
                                    exercise.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () {
                              context
                                  .read<RoutineProvider>()
                                  .addExerciseToCreation(exercise.id!);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
              ),
            ),
          ],
        );
      },
    );
  }
}

class EditExerciseDialog extends StatefulWidget {
  final int index;
  final RoutineExercise exercise;

  const EditExerciseDialog({
    super.key,
    required this.index,
    required this.exercise,
  });

  @override
  State<EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<EditExerciseDialog> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: '${widget.exercise.sets ?? 3}',
    );
    _repsController = TextEditingController(
      text: '${widget.exercise.reps ?? 10}',
    );
    _restController = TextEditingController(
      text: '${widget.exercise.restSeconds ?? 60}',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _setsController,
            decoration: const InputDecoration(
              labelText: 'Sets',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _repsController,
            decoration: const InputDecoration(
              labelText: 'Reps',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.repeat),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _restController,
            decoration: const InputDecoration(
              labelText: 'Rest (seconds)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.read<RoutineProvider>().updateExerciseInCreation(
              widget.index,
              sets: int.tryParse(_setsController.text),
              reps: int.tryParse(_repsController.text),
              restSeconds: int.tryParse(_restController.text),
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
