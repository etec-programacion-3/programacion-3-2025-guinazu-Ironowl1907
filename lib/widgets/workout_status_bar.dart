import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_exercise_provider.dart';
import 'package:workout_logger/providers/workout_set_provider.dart';

class WorkoutInfoCard extends StatefulWidget {
  const WorkoutInfoCard({super.key, required this.workout});

  final Workout workout;

  @override
  State<WorkoutInfoCard> createState() => _WorkoutInfoCardState();
}

class _WorkoutInfoCardState extends State<WorkoutInfoCard> {
  int _totalSets = 0;
  double _totalVolume = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutStats();
  }

  Future<void> _loadWorkoutStats() async {
    final List<DetailedWorkoutExercise> exercises = await context
        .read<WorkoutExerciseProvider>()
        .getDetailedWorkoutExercisesByWorkout(widget.workout.id!);

    int setsCount = 0;
    double volume = 0.0;

    for (final DetailedWorkoutExercise exercise in exercises) {
      final int workoutExerciseId = exercise.workoutExercise.id!;
      final List<WorkoutSet> sets = await context
          .read<WorkoutSetProvider>()
          .getByExercise(workoutExerciseId);

      final List<WorkoutSet> completedSets = sets
          .where((WorkoutSet set) => set.completed == 1)
          .toList();

      setsCount += completedSets.length;

      for (final WorkoutSet set in completedSets) {
        volume += (set.weightKg ?? 0) * (set.reps ?? 0);
      }
    }

    if (mounted) {
      setState(() {
        _totalSets = setsCount;
        _totalVolume = volume;
        _isLoading = false;
      });
    }
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

  String _formatDate(DateTime date) {
    final List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime time) {
    final int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.workout.title ?? 'Unnamed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.workout.startedAt != null)
              Text(
                _formatDate(widget.workout.startedAt!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12,
                      children: <Widget>[
                        _InfoChip(
                          title: 'Duration',
                          info: _formatDuration(),
                          icon: Icons.timer_outlined,
                        ),
                        _InfoChip(
                          title: 'Sets',
                          info: '$_totalSets',
                          icon: Icons.fitness_center,
                        ),
                        _InfoChip(
                          title: 'Volume',
                          info: '${_totalVolume.toStringAsFixed(0)} kg',
                          icon: Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.title,
    required this.info,
    required this.icon,
  });

  final String title;
  final String info;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                info,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
