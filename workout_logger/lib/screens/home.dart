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
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No logged workouts yet.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Create a free form workout",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _workoutList.length,
            itemBuilder: (context, index) {
              final workout = _workoutList[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(workout.title ?? "<Untitled>"),
                subtitle: Text("ID: ${workout.id}"),
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
