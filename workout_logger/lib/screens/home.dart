import 'package:flutter/material.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/models/models.dart'; // assuming Workout is defined here

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.updateCallback});

  final Function updateCallback;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Workout>> _workoutList;

  @override
  void initState() {
    super.initState();
    _workoutList = _loadWorkouts();
  }

  Future<List<Workout>> _loadWorkouts() {
    return DatabaseService.instance.getAllWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Workout>>(
      future: _workoutList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
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
          );
        } else {
          final workoutListData = snapshot.data!;
          return ListView.builder(
            itemCount: workoutListData.length,
            itemBuilder: (context, index) {
              final workout = workoutListData[index];
              return ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(workout.title ?? "<Untitled>"),
                subtitle: Text(
                  workout.endedAt == null
                      ? "Unfinished"
                      : workout.endedAt.toString(),
                ),
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Selected")));
                },
              );
            },
          );
        }
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
