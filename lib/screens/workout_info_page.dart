import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_exercise_provider.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/providers/workout_set_provider.dart';
import 'package:workout_logger/widgets/workout_status_bar.dart';

class WorkoutInfoPage extends StatefulWidget {
  const WorkoutInfoPage({super.key, required this.workout});
  final Workout workout;

  @override
  State<WorkoutInfoPage> createState() => _WorkoutInfoPageState();
}

class _WorkoutInfoPageState extends State<WorkoutInfoPage> {
  List<DetailedWorkoutExercise> _exercises = <DetailedWorkoutExercise>[];
  final Map<int, List<WorkoutSet>> _exerciseSets = <int, List<WorkoutSet>>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    _exercises = await context
        .read<WorkoutExerciseProvider>()
        .getDetailedWorkoutExercisesByWorkout(widget.workout.id!);

    for (int i = 0; i < _exercises.length; i++) {
      final DetailedWorkoutExercise exercise = _exercises[i];
      final int workoutExerciseId = exercise.workoutExercise.id!;

      final List<WorkoutSet> sets = await context
          .read<WorkoutSetProvider>()
          .getByExercise(workoutExerciseId);

      _exerciseSets[workoutExerciseId] = sets;
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatDuration() {
    if (widget.workout.startedAt == null || widget.workout.endedAt == null) {
      return 'N/A';
    }

    final Duration duration = widget.workout.endedAt!.difference(
      widget.workout.startedAt!,
    );
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int _calculateTotalSets() {
    int total = 0;
    for (List<WorkoutSet> sets in _exerciseSets.values) {
      total += sets.where((WorkoutSet set) => set.completed == 1).length;
    }
    return total;
  }

  double _calculateTotalVolume() {
    double volume = 0.0;
    for (List<WorkoutSet> sets in _exerciseSets.values) {
      for (WorkoutSet set in sets.where((WorkoutSet s) => s.completed == 1)) {
        volume += (set.weightKg ?? 0) * (set.reps ?? 0);
      }
    }
    return volume;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Detail'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                _handleEdit();
              } else if (value == 'delete') {
                _handleDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: <Widget>[
                  // Use the new reusable widget
                  WorkoutInfoCard(
                    workout: widget.workout,
                    totalSets: _calculateTotalSets(),
                    totalVolume: _calculateTotalVolume(),
                    duration: _formatDuration(),
                  ),
                  _buildExercisesSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildExercisesSection(ThemeData theme) {
    if (_exercises.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No exercises recorded',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Exercises',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._exercises.map(
          (DetailedWorkoutExercise exercise) =>
              _buildExerciseCard(exercise, theme),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(DetailedWorkoutExercise exercise, ThemeData theme) {
    final List<WorkoutSet> sets =
        _exerciseSets[exercise.workoutExercise.id] ?? <WorkoutSet>[];
    final List<WorkoutSet> completedSets = sets
        .where((WorkoutSet s) => s.completed == 1)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${exercise.workoutExercise.orderIndex}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exercise.exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${completedSets.length} of ${sets.length} sets completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (sets.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildSetsTable(sets, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetsTable(List<WorkoutSet> sets, ThemeData theme) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1),
      },
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            _buildTableHeader('Set', theme),
            _buildTableHeader('Reps', theme),
            _buildTableHeader('Weight', theme),
            _buildTableHeader('Status', theme),
          ],
        ),
        ...sets.map(
          (WorkoutSet set) => TableRow(
            children: <Widget>[
              _buildTableCell('${set.setNumber}', theme),
              _buildTableCell('${set.reps ?? '-'}', theme),
              _buildTableCell(
                set.weightKg != null ? '${set.weightKg} kg' : '-',
                theme,
              ),
              _buildTableCell(
                set.completed == 1 ? '✓' : '○',
                theme,
                color: set.completed == 1 ? Colors.green : Colors.grey[400],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, ThemeData theme, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: theme.textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }

  void _handleEdit() {
    print('Edit selected');
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout'),
          content: const Text('Are you sure you want to delete this workout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<WorkoutProvider>().delete(widget.workout.id!);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
