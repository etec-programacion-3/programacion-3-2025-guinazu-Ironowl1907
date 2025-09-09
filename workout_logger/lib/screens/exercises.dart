import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late Future<List<Exercise>> _exercisesFuture;
  List<MuscleGroup> _muscleGroups = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    _muscleGroups = await DatabaseService.instance.getAllMuscleGroups();
    _refreshExercises();
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = DatabaseService.instance.getAllExercises();
    });
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    await DatabaseService.instance.deleteExercise(exercise.id!);
    _refreshExercises();
  }

  Future<void> _editExerciseDialog(Exercise exercise) async {
    final nameController = TextEditingController(text: exercise.name);
    final descriptionController = TextEditingController(
      text: exercise.description ?? '',
    );
    MuscleGroup? selectedMuscleGroup;

    // Find the current muscle group
    if (exercise.muscleGroupId != null) {
      selectedMuscleGroup = _muscleGroups.firstWhere(
        (mg) => mg.id == exercise.muscleGroupId,
        orElse: () => _muscleGroups.isNotEmpty
            ? _muscleGroups.first
            : MuscleGroup(name: 'None'),
      );
    } else {
      selectedMuscleGroup = _muscleGroups.isNotEmpty
          ? _muscleGroups.first
          : null;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    hintText: "Enter exercise name",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                    hintText: "Enter description",
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (_muscleGroups.isNotEmpty)
                  DropdownButtonFormField<MuscleGroup>(
                    value: selectedMuscleGroup,
                    decoration: const InputDecoration(
                      labelText: "Muscle Group",
                    ),
                    items: _muscleGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMuscleGroup = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop({
                    'name': name,
                    'description': descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    'muscleGroupId': selectedMuscleGroup?.id,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedExercise = Exercise(
        id: exercise.id,
        name: result['name'],
        description: result['description'],
        muscleGroupId: result['muscleGroupId'],
      );
      await DatabaseService.instance.updateExercise(updatedExercise);
      _refreshExercises();
    }
  }

  Future<void> _addExerciseDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    MuscleGroup? selectedMuscleGroup = _muscleGroups.isNotEmpty
        ? _muscleGroups.first
        : null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    hintText: "Enter exercise name",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                    hintText: "Enter description",
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (_muscleGroups.isNotEmpty)
                  DropdownButtonFormField<MuscleGroup>(
                    value: selectedMuscleGroup,
                    decoration: const InputDecoration(
                      labelText: "Muscle Group",
                    ),
                    items: _muscleGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMuscleGroup = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop({
                    'name': name,
                    'description': descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    'muscleGroupId': selectedMuscleGroup?.id,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final exercise = Exercise(
        name: result['name'],
        description: result['description'],
        muscleGroupId: result['muscleGroupId'],
      );
      await DatabaseService.instance.insertExercise(exercise);
      _refreshExercises();
    }
  }

  String _getMuscleGroupName(int? muscleGroupId) {
    if (muscleGroupId == null) return 'No muscle group';
    final muscleGroup = _muscleGroups.firstWhere(
      (mg) => mg.id == muscleGroupId,
      orElse: () => MuscleGroup(name: 'Unknown'),
    );
    return muscleGroup.name;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Exercises")),
      body: FutureBuilder<List<Exercise>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No exercises yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap + to add your first exercise",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return exerciseCard(exercise, exercises, index, colorScheme);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExerciseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Dismissible exerciseCard(
    Exercise exercise,
    List<Exercise> exerciseList,
    int index,
    ColorScheme colorScheme,
  ) {
    return Dismissible(
      key: ValueKey(exercise.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _deleteExercise(exercise);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // You could implement undo functionality here
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _editExerciseDialog(exercise),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/edit.svg',
                      width: 24,
                      height: 24,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                        _getMuscleGroupName(exercise.muscleGroupId),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      exercise.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
