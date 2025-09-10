import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class CreateRoutinePage extends StatefulWidget {
  final Routine? routine; // For editing existing routine

  const CreateRoutinePage({super.key, this.routine});

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Exercise> _availableExercises = [];
  List<MuscleGroup> _muscleGroups = [];
  List<RoutineExerciseItem> _selectedExercises = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.routine != null;
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _availableExercises = await DatabaseService.instance.getAllExercises();
      _muscleGroups = await DatabaseService.instance.getAllMuscleGroups();

      if (_isEditing && widget.routine != null) {
        _nameController.text = widget.routine!.name;
        _descriptionController.text = widget.routine!.description ?? '';
        await _loadExistingRoutineExercises();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadExistingRoutineExercises() async {
    if (widget.routine?.id == null) return;

    final routineExercises = await DatabaseService.instance
        .getRoutineExercisesByRoutine(widget.routine!.id!);

    final List<RoutineExerciseItem> items = [];

    for (final routineExercise in routineExercises) {
      final exercise = _availableExercises.firstWhere(
        (e) => e.id == routineExercise.exerciseId,
        orElse: () => Exercise(name: 'Unknown Exercise'),
      );

      items.add(
        RoutineExerciseItem(
          exercise: exercise,
          sets: routineExercise.sets ?? 3,
          reps: routineExercise.reps ?? 10,
          restSeconds: routineExercise.restSeconds ?? 60,
        ),
      );
    }

    setState(() {
      _selectedExercises = items;
    });
  }

  String _getMuscleGroupName(int? muscleGroupId) {
    if (muscleGroupId == null) return 'No muscle group';
    final muscleGroup = _muscleGroups.firstWhere(
      (mg) => mg.id == muscleGroupId,
      orElse: () => MuscleGroup(name: 'Unknown'),
    );
    return muscleGroup.name;
  }

  Future<void> _addExerciseDialog() async {
    if (_availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No exercises available. Please create some exercises first.',
          ),
        ),
      );
      return;
    }

    Exercise? selectedExercise;
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final restController = TextEditingController(text: '60');
    final notesController = TextEditingController();

    final result = await showDialog<RoutineExerciseItem>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Exercise>(
                  value: selectedExercise,
                  decoration: const InputDecoration(
                    labelText: "Exercise",
                    border: OutlineInputBorder(),
                  ),
                  items: _availableExercises.map((exercise) {
                    return DropdownMenuItem(
                      value: exercise,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _getMuscleGroupName(exercise.muscleGroupId),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedExercise = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: "Sets",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: "Reps",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: restController,
                  decoration: const InputDecoration(
                    labelText: "Rest (seconds)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: "Notes (optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedExercise != null &&
                    setsController.text.isNotEmpty &&
                    repsController.text.isNotEmpty &&
                    restController.text.isNotEmpty) {
                  final item = RoutineExerciseItem(
                    exercise: selectedExercise!,
                    sets: int.parse(setsController.text),
                    reps: int.parse(repsController.text),
                    restSeconds: int.parse(restController.text),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  Navigator.of(context).pop(item);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      // Check if exercise is already added
      final existingIndex = _selectedExercises.indexWhere(
        (item) => item.exercise.id == result.exercise.id,
      );

      if (existingIndex != -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise is already added to this routine'),
          ),
        );
      } else {
        setState(() {
          _selectedExercises.add(result);
        });
      }
    }
  }

  Future<void> _editExerciseDialog(int index) async {
    final item = _selectedExercises[index];
    final setsController = TextEditingController(text: item.sets.toString());
    final repsController = TextEditingController(text: item.reps.toString());
    final restController = TextEditingController(
      text: item.restSeconds.toString(),
    );
    final notesController = TextEditingController(text: item.notes ?? '');

    final result = await showDialog<RoutineExerciseItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.exercise.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: "Sets",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: "Reps",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: restController,
                decoration: const InputDecoration(
                  labelText: "Rest (seconds)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes (optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (setsController.text.isNotEmpty &&
                  repsController.text.isNotEmpty &&
                  restController.text.isNotEmpty) {
                final updatedItem = RoutineExerciseItem(
                  exercise: item.exercise,
                  sets: int.parse(setsController.text),
                  reps: int.parse(repsController.text),
                  restSeconds: int.parse(restController.text),
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                Navigator.of(context).pop(updatedItem);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedExercises[index] = result;
      });
    }
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, item);
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate() || _selectedExercises.isEmpty) {
      if (_selectedExercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise to the routine'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int routineId;

      if (_isEditing && widget.routine != null) {
        // Update existing routine
        final updatedRoutine = Routine(
          id: widget.routine!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        await DatabaseService.instance.updateRoutine(updatedRoutine);
        routineId = widget.routine!.id!;

        // Delete existing routine exercises
        await DatabaseService.instance.deleteRoutineExercisesByRoutine(
          routineId,
        );
      } else {
        // Create new routine
        final routine = Routine(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        routineId = await DatabaseService.instance.insertRoutine(routine);
      }

      // Insert routine exercises
      for (int i = 0; i < _selectedExercises.length; i++) {
        final item = _selectedExercises[i];
        final routineExercise = RoutineExercise(
          routineId: routineId,
          exerciseId: item.exercise.id!,
          sets: item.sets,
          reps: item.reps,
          restSeconds: item.restSeconds,
        );

        await DatabaseService.instance.insertRoutineExercise(routineExercise);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Routine updated successfully'
                  : 'Routine created successfully',
            ),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving routine: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Routine" : "Create Routine"),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveRoutine,
              child: Text(
                _isEditing ? "UPDATE" : "SAVE",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Routine Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Routine Name",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fitness_center),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a routine name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Description (optional)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  // Exercises Section Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Exercises (${_selectedExercises.length})",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addExerciseDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Exercise"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Exercises List
                  Expanded(
                    child: _selectedExercises.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No exercises added yet",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tap 'Add Exercise' to get started",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _selectedExercises.length,
                            onReorder: _reorderExercises,
                            itemBuilder: (context, index) {
                              final item = _selectedExercises[index];
                              return _buildExerciseCard(
                                item,
                                index,
                                colorScheme,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildExerciseCard(
    RoutineExerciseItem item,
    int index,
    ColorScheme colorScheme,
  ) {
    return Card(
      key: ValueKey(item.exercise.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.drag_handle,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.exercise.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                          _getMuscleGroupName(item.exercise.muscleGroupId),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editExerciseDialog(index),
                  icon: Icon(Icons.edit, color: colorScheme.onPrimaryContainer),
                ),
                IconButton(
                  onPressed: () => _removeExercise(index),
                  icon: Icon(Icons.delete, color: colorScheme.error),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip("${item.sets} sets", Icons.repeat, colorScheme),
                const SizedBox(width: 8),
                _buildInfoChip(
                  "${item.reps} reps",
                  Icons.fitness_center,
                  colorScheme,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  "${item.restSeconds}s rest",
                  Icons.timer,
                  colorScheme,
                ),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  item.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class to hold exercise data for the routine
class RoutineExerciseItem {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;

  RoutineExerciseItem({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes,
  });
}
