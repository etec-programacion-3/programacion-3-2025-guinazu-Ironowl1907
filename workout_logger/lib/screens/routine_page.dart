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
  void initState() {
    super.initState();
    _routineFuture = DatabaseService.instance.getAllRoutines();
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

  Dismissible routineCard(Routine routine, int index, ColorScheme colorScheme) {
    return Dismissible(
      key: ValueKey(routine.id),
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
        _deleteRoutine(routine);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${routine.name} deleted'),
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
        // onTap: () => _editExerciseDialog(exercise),
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
                        routine.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Icon(Icons.edit),
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
                        // _getMuscleGroupName(exercise.muscleGroupId),
                        "Placeholder",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                if (routine.description != null &&
                    routine.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      routine.description!,
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
