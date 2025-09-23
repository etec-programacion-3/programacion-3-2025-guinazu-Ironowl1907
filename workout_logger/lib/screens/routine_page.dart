import 'package:flutter/material.dart';
import 'package:workout_logger/screens/routine_details.dart';
import 'package:workout_logger/widgets/routine_card.dart';
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

  // Add this method to the _RoutinePageState class in your RoutinePage

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Routines")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (context) => const CreateRoutinePage(),
            ),
          );

          if (result == true) {
            _refreshRoutines();
          }
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
              return routineCard(routine, colorScheme, _refreshRoutines);
            },
          );
        },
      ),
    );
  }
}
