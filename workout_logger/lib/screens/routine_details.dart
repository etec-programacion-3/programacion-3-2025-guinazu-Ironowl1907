import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'newRoutine.dart';

class RoutineDetailsPage extends StatefulWidget {
  final Routine routine;

  const RoutineDetailsPage({super.key, required this.routine});

  @override
  State<RoutineDetailsPage> createState() => _RoutineDetailsPageState();
}

class _RoutineDetailsPageState extends State<RoutineDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RoutineExerciseItem> _exercises = [];
  List<MuscleGroup> _muscleGroups = [];
  List<Workout> _workoutHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load muscle groups for display
      _muscleGroups = await DatabaseService.instance.getAllMuscleGroups();

      // Load routine exercises
      final routineExercises = await DatabaseService.instance
          .getRoutineExercisesByRoutine(widget.routine.id!);

      final availableExercises = await DatabaseService.instance
          .getAllExercises();

      final List<RoutineExerciseItem> exercises = [];

      for (final routineExercise in routineExercises) {
        final exercise = availableExercises.firstWhere(
          (e) => e.id == routineExercise.exerciseId,
          orElse: () => Exercise(name: 'Unknown Exercise'),
        );

        exercises.add(
          RoutineExerciseItem(
            exercise: exercise,
            sets: routineExercise.sets ?? 3,
            reps: routineExercise.reps ?? 10,
            restSeconds: routineExercise.restSeconds ?? 60,
          ),
        );
      }

      // Load workout history
      _workoutHistory = await DatabaseService.instance.getWorkoutsByRoutine(
        widget.routine.id!,
      );

      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading routine data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  int _calculateEstimatedDuration() {
    if (_exercises.isEmpty) return 0;

    int totalTime = 0;
    for (final exercise in _exercises) {
      // Estimate time per set (45 seconds) + rest time
      // TODO : Hack implementation
      final timePerSet = 45 + exercise.restSeconds;
      totalTime += exercise.sets * timePerSet;
    }

    // Add 5 minutes for warm-up/cool-down
    totalTime += 300;

    return (totalTime / 60).round(); // Convert to minutes
  }

  Future<void> _startWorkout() async {
    // TODO: Implement start workout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Start workout functionality')),
    );
  }

  Future<void> _editRoutine() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => CreateRoutinePage(routine: widget.routine),
      ),
    );

    if (result == true) {
      _loadData(); // Refresh data after edit
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editRoutine),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(colorScheme),
                _buildProgressTab(colorScheme),
                _buildHistoryTab(colorScheme),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startWorkout,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Workout'),
      ),
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Routine Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: colorScheme.primaryContainer,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.routine.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (widget.routine.description != null &&
                        widget.routine.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.routine.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatChip(
                          "${_exercises.length} exercises",
                          Icons.fitness_center,
                          colorScheme,
                        ),
                        _buildStatChip(
                          "~${_calculateEstimatedDuration()} min",
                          Icons.timer,
                          colorScheme,
                        ),
                        _buildStatChip(
                          "${_workoutHistory.length} workouts",
                          Icons.history,
                          colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Exercises Section
          Text(
            "Exercises",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          if (_exercises.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No exercises in this routine",
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_exercises.length, (index) {
              final exercise = _exercises[index];
              return _buildExerciseCard(exercise, index + 1, colorScheme);
            }),
        ],
      ),
    );
  }

  Widget _buildProgressTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress Tracking",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Overview Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 32,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total Volume",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          "TODO",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 32,
                          color: colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Avg Duration",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          "TODO",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: Container(
              width: double.infinity,

              height: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Progress Chart",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Volume and strength progression over time",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "TODO: Implement chart with workout data",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Exercise Progress List
          Text(
            "Exercise Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          if (_exercises.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "No exercises to track",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            )
          else
            ...List.generate(_exercises.length, (index) {
              final exercise = _exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.fitness_center,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(exercise.exercise.name),
                  subtitle: Text("TODO: Last performed weight/reps"),
                  trailing: Icon(Icons.trending_up, color: colorScheme.primary),
                  onTap: () {
                    // TODO: Navigate to exercise progress details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'TODO: Show ${exercise.exercise.name} progress details',
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Workout History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          if (_workoutHistory.isEmpty)
            Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No workout history yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start your first workout to see history here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...List.generate(_workoutHistory.length, (index) {
              final workout = _workoutHistory[index];
              return _buildWorkoutHistoryCard(workout, colorScheme);
            }),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    RoutineExerciseItem exercise,
    int order,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      order.toString(),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getMuscleGroupName(exercise.exercise.muscleGroupId),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  "${exercise.sets} sets",
                  Icons.repeat,
                  colorScheme,
                ),
                _buildInfoChip(
                  "${exercise.reps} reps",
                  Icons.fitness_center,
                  colorScheme,
                ),
                _buildInfoChip(
                  "${exercise.restSeconds}s rest",
                  Icons.timer,
                  colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(Workout workout, ColorScheme colorScheme) {
    final duration = workout.endedAt?.difference(workout.startedAt!).inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: workout.endedAt != null
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer,
          child: Icon(
            workout.endedAt != null ? Icons.check : Icons.play_arrow,
            color: workout.endedAt != null
                ? colorScheme.onPrimaryContainer
                : colorScheme.onErrorContainer,
          ),
        ),
        title: Text(
          workout.endedAt != null ? "Completed Workout" : "In Progress",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${workout.startedAt!.day}/${workout.startedAt!.month}/${workout.startedAt!.year} at ${workout.startedAt!.hour.toString().padLeft(2, '0')}:${workout.startedAt!.minute.toString().padLeft(2, '0')}",
            ),
            if (duration != null)
              Text("Duration: $duration minutes")
            else
              const Text("In progress..."),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to workout details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TODO: Show workout details')),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
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

// Helper class to hold exercise data for the routine (if not already defined)
class RoutineExerciseItem {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int restSeconds;

  RoutineExerciseItem({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });
}
