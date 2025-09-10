import 'package:flutter/material.dart';
import 'newRoutine.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late Future<List<Routine>> _routineFuture;

  @override
  void initState() {
    super.initState();
    _routineFuture = DatabaseService.instance.getAllRoutines();
  }

  void _refreshRoutines() {
    setState(() {
      _routineFuture = DatabaseService.instance.getAllRoutines();
    });
  }

  Future<void> _deleteRoutine(Routine routine) async {
    await DatabaseService.instance.deleteRoutine(routine.id!);
    _refreshRoutines();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Routines")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const CreateRoutinePage(),
            ),
          );
        },
      ),

      body: FutureBuilder<List<Routine>>(
        future: _routineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final routines = snapshot.data ?? [];

          if (routines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No routines yet.",
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
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final routine = routines[index];
              return routineCard(routine, index, colorScheme);
            },
          );
        },
      ),
    );
  }

  void _showRoutineMenu(Routine routine) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Workout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to workout session page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: Start workout functionality'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Routine'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit routine page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: Edit routine functionality'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Routine'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement duplicate routine functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: Duplicate routine functionality'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Routine'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share routine functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: Share routine functionality'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Routine',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(routine);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Routine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text(
          'Are you sure you want to delete "${routine.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRoutine(routine);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${routine.name} deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Card routineCard(Routine routine, int index, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to routine details page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TODO: Navigate to routine details')),
          );
        },
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
                      routine.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showRoutineMenu(routine),
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              if (routine.description != null &&
                  routine.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  routine.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Exercise count and duration info
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
                      // TODO: Get actual exercise count from routine.exercises.length
                      "0 exercises", // Placeholder until we have access to exercises
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      // TODO: Calculate estimated duration based on exercises
                      "~45 min", // Placeholder
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Exercise preview
              Text(
                "Exercises:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              // TODO: Replace with actual exercises from routine
              _buildExercisePreview(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisePreview(ColorScheme colorScheme) {
    // TODO: Get actual exercises from routine.exercises
    // For now, showing placeholder exercises
    final placeholderExercises = [
      "Bench Press",
      "Squats",
      "Deadlifts",
      "Pull-ups",
    ];

    if (placeholderExercises.isEmpty) {
      return Text(
        "No exercises added yet",
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onPrimaryContainer.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...placeholderExercises
            .take(3)
            .map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      exercise,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        if (placeholderExercises.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "+${placeholderExercises.length - 3} more exercises",
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimaryContainer.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
