import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class FreeFormWorkoutPage extends StatefulWidget {
  const FreeFormWorkoutPage({super.key});

  @override
  State<FreeFormWorkoutPage> createState() => _FreeFormWorkoutPageState();
}

class _FreeFormWorkoutPageState extends State<FreeFormWorkoutPage> {
  final DatabaseService _dbService = DatabaseService.instance;

  // Workout tracking
  Workout? _currentWorkout;
  DateTime? _workoutStartTime;
  Duration _workoutDuration = Duration.zero;

  // Exercise data
  List<Exercise> _exercises = [];
  final List<WorkoutExerciseLog> _exerciseLogs = [];

  // UI State
  bool _isWorkoutActive = false;
  bool _isLoading = true;

  // Statistics
  int _totalSets = 0;
  double _totalVolume = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  void _startTimer() {
    // Update workout duration every second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isWorkoutActive && mounted) {
        setState(() {
          _workoutDuration = DateTime.now().difference(_workoutStartTime!);
        });
        _startTimer();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      final exercises = await _dbService.getAllExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load exercises: $e');
    }
  }

  Future<void> _startWorkout() async {
    try {
      _workoutStartTime = DateTime.now();
      final workout = Workout(
        routineId: null, // Free form workout
        startedAt: _workoutStartTime,
      );

      final workoutId = await _dbService.insertWorkout(workout);
      workout.id = workoutId;

      setState(() {
        _currentWorkout = workout;
        _isWorkoutActive = true;
        _workoutDuration = Duration.zero;
      });

      _showSuccessSnackBar('Workout started!');
    } catch (e) {
      _showErrorSnackBar('Failed to start workout: $e');
    }
  }

  Future<void> _endWorkout() async {
    if (_currentWorkout == null) return;

    try {
      await _dbService.endWorkout(_currentWorkout!.id!);

      setState(() {
        _isWorkoutActive = false;
        _currentWorkout = null;
        _exerciseLogs.clear();
        _totalSets = 0;
        _totalVolume = 0.0;
      });

      _showSuccessSnackBar('Workout completed!');
    } catch (e) {
      _showErrorSnackBar('Failed to end workout: $e');
    }
  }

  void _addExerciseLog(Exercise exercise) {
    setState(() {
      _exerciseLogs.add(WorkoutExerciseLog(exercise: exercise));
    });
  }

  void _removeExerciseLog(int index) {
    setState(() {
      final log = _exerciseLogs[index];
      _totalSets -= log.sets.length;
      _totalVolume -= log.getTotalVolume();
      _exerciseLogs.removeAt(index);
    });
  }

  void _updateStatistics() {
    int sets = 0;
    double volume = 0.0;

    for (final log in _exerciseLogs) {
      sets += log.sets.length;
      volume += log.getTotalVolume();
    }

    setState(() {
      _totalSets = sets;
      _totalVolume = volume;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Form Workout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isWorkoutActive)
            IconButton(
              onPressed: _endWorkout,
              icon: const Icon(Icons.stop),
              tooltip: 'End Workout',
            ),
        ],
      ),
      body: Column(
        children: [
          // Workout Stats Header
          _buildWorkoutStatsHeader(),

          // Exercise List
          Expanded(
            child: _isWorkoutActive
                ? _buildActiveWorkoutView()
                : _buildStartWorkoutView(),
          ),
        ],
      ),
      floatingActionButton: _isWorkoutActive
          ? FloatingActionButton(
              onPressed: _showAddExerciseDialog,
              tooltip: 'Add Exercise',
              child: const Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              onPressed: _startWorkout,
              label: const Text('Start Workout'),
              icon: const Icon(Icons.play_arrow),
            ),
    );
  }

  Widget _buildWorkoutStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            'Time',
            _isWorkoutActive ? _formatDuration(_workoutDuration) : '00:00:00',
            Icons.timer,
            Colors.blue,
          ),
          _buildStatCard(
            'Sets',
            _totalSets.toString(),
            Icons.fitness_center,
            Colors.orange,
          ),
          _buildStatCard(
            'Volume',
            '${_totalVolume.toStringAsFixed(1)} kg',
            Icons.trending_up,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStartWorkoutView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Ready to start your workout?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to begin',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutView() {
    if (_exerciseLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Add your first exercise',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _exerciseLogs.length,
      itemBuilder: (context, index) {
        return _buildExerciseLogCard(_exerciseLogs[index], index);
      },
    );
  }

  Widget _buildExerciseLogCard(WorkoutExerciseLog log, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    log.exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeExerciseLog(index),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sets List
            ...log.sets.asMap().entries.map((entry) {
              int setIndex = entry.key;
              WorkoutSet set = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('${setIndex + 1}:')),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: set.weight?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final weight = double.tryParse(value);
                                log.updateSet(setIndex, weight: weight);
                                _updateStatistics();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: set.reps?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final reps = int.tryParse(value);
                                log.updateSet(setIndex, reps: reps);
                                _updateStatistics();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        log.removeSet(setIndex);
                        _updateStatistics();
                        setState(() {});
                      },
                      icon: const Icon(Icons.remove_circle),
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            }),

            // Add Set Button
            TextButton.icon(
              onPressed: () {
                log.addSet();
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(exercise.description ?? ''),
                onTap: () {
                  _addExerciseLog(exercise);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Helper classes for managing workout data
class WorkoutExerciseLog {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  WorkoutExerciseLog({required this.exercise, List<WorkoutSet>? sets})
    : sets = sets ?? [WorkoutSet()];

  void addSet() {
    sets.add(WorkoutSet());
  }

  void removeSet(int index) {
    if (sets.length > 1) {
      sets.removeAt(index);
    }
  }

  void updateSet(int index, {double? weight, int? reps}) {
    if (index < sets.length) {
      sets[index] = sets[index].copyWith(weight: weight, reps: reps);
    }
  }

  double getTotalVolume() {
    return sets.fold(0.0, (sum, set) {
      final weight = set.weight ?? 0.0;
      final reps = set.reps ?? 0;
      return sum + (weight * reps);
    });
  }

  // TODO: Implement saving sets to database
  Future<void> saveToDatabase(int workoutId, DatabaseService dbService) async {
    // This will save all sets to the workout_logs table
    for (int i = 0; i < sets.length; i++) {
      final set = sets[i];
      if (set.weight != null && set.reps != null) {
        final workoutLog = WorkoutLog(
          workoutId: workoutId,
          exerciseId: exercise.id!,
          setNumber: i + 1,
          reps: set.reps,
          weightKg: set.weight,
          restSeconds: set.restSeconds,
        );
        await dbService.insertWorkoutLog(workoutLog);
      }
    }
  }
}

class WorkoutSet {
  double? weight;
  int? reps;
  int? restSeconds;

  WorkoutSet({this.weight, this.reps, this.restSeconds});

  WorkoutSet copyWith({double? weight, int? reps, int? restSeconds}) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

// TODO: List:
// 1. Implement rest timer between sets
// 2. Add exercise search/filter functionality in the add exercise dialog
// 3. Implement exercise history display (previous weights/reps for each exercise)
// 4. Add workout templates functionality
// 5. Implement data persistence during workout (save progress in case app is closed)
// 6. Add workout notes functionality
// 7. Implement exercise reordering (drag and drop)
// 8. Add superset support
// 9. Implement workout analytics and progress tracking
// 10. Add export workout data functionality
// 11. Implement muscle group filtering for exercises
// 12. Add custom exercise creation from within the workout
