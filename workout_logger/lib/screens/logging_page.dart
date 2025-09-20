import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key, this.routine, this.inProgressWorkout});

  final Routine? routine;
  final Workout? inProgressWorkout;

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  Workout? _currentWorkout;
  Routine? _currentRoutine;
  List<DetailedRoutineExercise> _routineExercises = [];
  List<WorkoutExercise> _workoutExercises = [];
  bool _isLoading = true;
  int _currentExerciseIndex = 0;

  final DatabaseService _dbService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeWorkout() async {
    try {
      if (widget.inProgressWorkout != null) {
        await _resumeWorkout();
      } else if (widget.routine != null) {
        await _startRoutineWorkout();
      } else {
        await _startFreeFormWorkout();
      }
    } catch (e) {
      _showErrorDialog('Failed to initialize workout: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resumeWorkout() async {
    _currentWorkout = widget.inProgressWorkout!;

    if (_currentWorkout!.routineId != null) {
      _currentRoutine = await _dbService.getRoutine(
        _currentWorkout!.routineId!,
      );
      _routineExercises = await _dbService.getDetailedRoutineExercisesByRoutine(
        _currentWorkout!.routineId!,
      );
    }

    _workoutExercises = await _dbService.getWorkoutExercisesByWorkout(
      _currentWorkout!.id!,
    );
  }

  Future<void> _startRoutineWorkout() async {
    _currentRoutine = widget.routine!;

    _routineExercises = await _dbService.getDetailedRoutineExercisesByRoutine(
      _currentRoutine!.id!,
    );

    final newWorkout = Workout(
      title: _currentRoutine!.name,
      routineId: _currentRoutine!.id,
      startedAt: DateTime.now(),
    );

    final workoutId = await _dbService.createWorkout(newWorkout);
    _currentWorkout = newWorkout..id = workoutId;

    for (int i = 0; i < _routineExercises.length; i++) {
      final routineExercise = _routineExercises[i].routineExercise;
      final workoutExercise = WorkoutExercise(
        workoutId: workoutId,
        exerciseId: routineExercise.exerciseId,
        orderIndex: i,
      );

      final workoutExerciseId = await _dbService.createWorkoutExercise(
        workoutExercise,
      );
      _workoutExercises.add(workoutExercise..id = workoutExerciseId);
    }
  }

  Future<void> _startFreeFormWorkout() async {
    final newWorkout = Workout(
      title: 'Free Form Workout',
      startedAt: DateTime.now(),
    );

    final workoutId = await _dbService.createWorkout(newWorkout);
    _currentWorkout = newWorkout..id = workoutId;
  }

  Future<void> _addExerciseToWorkout(Exercise exercise) async {
    if (_currentWorkout == null) return;

    final workoutExercise = WorkoutExercise(
      workoutId: _currentWorkout!.id!,
      exerciseId: exercise.id!,
      orderIndex: _workoutExercises.length,
    );

    final id = await _dbService.createWorkoutExercise(workoutExercise);

    setState(() {
      _workoutExercises.add(workoutExercise..id = id);
    });
  }

  void _finishCurrentExercise() {
    if (_currentExerciseIndex < _workoutExercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  void _goToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  Future<void> _finishWorkout() async {
    if (_currentWorkout == null) return;

    _currentWorkout!.endedAt = DateTime.now();
    await _dbService.updateWorkout(_currentWorkout!);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentWorkout?.title ?? "Logging workout"),
        actions: [
          if (_currentWorkout != null)
            TextButton(
              onPressed: _finishWorkout,
              child: const Text(
                'Finish',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildWorkoutContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWorkoutContent() {
    if (_currentWorkout == null) {
      return const Center(child: Text('No workout in progress'));
    }

    if (_workoutExercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises added yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add exercises',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Workout progress indicator
        LinearProgressIndicator(
          value: (_currentExerciseIndex + 1) / _workoutExercises.length,
        ),

        // Current exercise info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Exercise ${_currentExerciseIndex + 1} of ${_workoutExercises.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // Exercise content area
        Expanded(
          child: Center(
            child: Text(
              'Current Exercise: ${_getCurrentExerciseName()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _currentExerciseIndex > 0
                    ? _goToPreviousExercise
                    : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: _finishCurrentExercise,
                child: Text(
                  _currentExerciseIndex < _workoutExercises.length - 1
                      ? 'Next'
                      : 'Finish',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    // Show FAB only for free-form workouts
    if (_currentRoutine != null) return null;

    return FloatingActionButton(
      onPressed: () {
        // Navigate to exercise selection page
        // This would open a dialog or new page to select exercises
        _showExerciseSelectionDialog();
      },
      child: const Icon(Icons.add),
    );
  }

  String _getCurrentExerciseName() {
    if (_currentExerciseIndex >= _workoutExercises.length) {
      return 'No exercise';
    }

    if (_currentExerciseIndex < _routineExercises.length) {
      return _routineExercises[_currentExerciseIndex].exercise.name;
    }

    return 'Exercise ${_currentExerciseIndex + 1}';
  }

  void _showExerciseSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: const Text('Exercise selection would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
