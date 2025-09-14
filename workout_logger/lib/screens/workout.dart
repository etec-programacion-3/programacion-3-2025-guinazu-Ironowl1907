import 'package:flutter/material.dart';
import 'package:workout_logger/screens/freeform_workout.dart';
import 'package:workout_logger/utils/workout_utils.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Start",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            MenuButton(
              label: "Free Form",
              icon: Icon(Icons.add, size: 28),
              onPressed: () => _handleFreeFormStart(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFreeFormStart(BuildContext context) async {
    try {
      // Check for active workout
      final activeWorkoutData = await WorkoutUtils.getActiveWorkout();

      if (activeWorkoutData != null) {
        // Show dialog if active workout exists
        final action = await WorkoutUtils.showActiveWorkoutDialog(
          context,
          activeWorkoutData.workout,
          activeWorkoutData.logs,
        );

        if (action == null) return; // User cancelled dialog

        switch (action) {
          case WorkoutAction.continue_:
            _navigateToFreeForm(context, activeWorkoutData);
            break;
          case WorkoutAction.startNew:
            await WorkoutUtils.endWorkout(activeWorkoutData.workout.id!);
            _navigateToFreeForm(context, null);
            break;
          case WorkoutAction.discard:
            await WorkoutUtils.endWorkout(activeWorkoutData.workout.id!);
            _navigateToFreeForm(context, null);
            break;
        }
      } else {
        // No active workout, start fresh
        _navigateToFreeForm(context, null);
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking for active workout: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _navigateToFreeForm(
    BuildContext context,
    ActiveWorkoutData? activeData,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FreeFormWorkoutPage(activeWorkoutData: activeData),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed ?? () => print(label),
        icon: icon,
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

PreferredSizeWidget workoutAppBar() {
  return AppBar(
    title: const Text("Workout"),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Builder(
        builder: (context) {
          final dividerColor = Theme.of(context).dividerColor;
          return Container(color: dividerColor, height: 1.0);
        },
      ),
    ),
  );
}
