import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutUtils {
  /// Checks if there's an active workout and returns it along with its logs
  static Future<ActiveWorkoutData?> getActiveWorkout() async {
    final db = DatabaseService.instance;
    final workouts = await db.getAllWorkouts();

    final activeWorkout = workouts.where((w) => w.endedAt == null).firstOrNull;

    if (activeWorkout != null) {
      final logs = await db.getWorkoutLogsByWorkout(activeWorkout.id!);
      return ActiveWorkoutData(workout: activeWorkout, logs: logs);
    }

    return null;
  }

  /// Shows a dialog asking user what to do with an existing active workout
  static Future<WorkoutAction?> showActiveWorkoutDialog(
    BuildContext context,
    Workout activeWorkout,
    List<WorkoutLog> logs,
  ) async {
    final duration = DateTime.now().difference(activeWorkout.startedAt!);
    final volume = logs.fold<double>(
      0,
      (sum, l) => sum + (l.weightKg ?? 0) * (l.reps ?? 0),
    );
    final sets = logs.length;

    return showDialog<WorkoutAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text('Active Workout Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You have an ongoing workout:'),
              const SizedBox(height: 16),
              _buildWorkoutSummaryCard(
                context,
                duration: duration,
                volume: volume,
                sets: sets,
              ),
              const SizedBox(height: 16),
              const Text(
                'What would you like to do?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(WorkoutAction.discard),
              child: Text(
                'Discard',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(WorkoutAction.startNew),
              child: const Text('Start New'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(WorkoutAction.continue_),
              child: const Text('Resume'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildWorkoutSummaryCard(
    BuildContext context, {
    required Duration duration,
    required double volume,
    required int sets,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn("Duration", _formatDuration(duration)),
          _buildStatColumn("Volume", "${volume.toStringAsFixed(0)} kg"),
          _buildStatColumn("Sets", "$sets"),
        ],
      ),
    );
  }

  static Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  /// Ends the given workout
  static Future<void> endWorkout(int workoutId) async {
    final db = DatabaseService.instance;
    await db.endWorkout(workoutId);
  }
}

/// Data class to hold active workout information
class ActiveWorkoutData {
  final Workout workout;
  final List<WorkoutLog> logs;

  ActiveWorkoutData({required this.workout, required this.logs});
}

/// Enum for workout dialog actions
enum WorkoutAction { continue_, startNew, discard }
