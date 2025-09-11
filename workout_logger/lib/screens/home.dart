import 'package:flutter/material.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/models/models.dart'; // assuming Workout is defined here

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workout> _workoutList = []; // mutable, not final

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await DatabaseService.instance.getAllWorkouts();
    setState(() {
      _workoutList = workouts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _workoutList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _workoutList.length,
            itemBuilder: (context, index) {
              final workout = _workoutList[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text("Workout name"), // adjust property name
                subtitle: Text("ID: ${workout.id}"), // just an example
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Selected")));
                },
              );
            },
          );
  }
}

PreferredSizeWidget homeAppBar() {
  return AppBar(
    title: const Text("Home"),
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
