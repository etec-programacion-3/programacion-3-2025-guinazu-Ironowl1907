import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/screens/workout_info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<WorkoutProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (BuildContext context, WorkoutProvider provider, _) {
        if (provider.workouts == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.workouts!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No workouts logged yet!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        }

        return workoutCard(provider);
      },
    );
  }

  Widget workoutCard(WorkoutProvider provider) {
    return ListView.builder(
      itemCount: provider.workouts!.length,
      itemBuilder: (BuildContext context, int index) {
        final Workout workout = provider.workouts![index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => WorkoutInfoPage(workout: workout),
              ),
            );
          },

          child: ListTile(
            title: Text(workout.title ?? 'Workout ${index + 1}'),
            subtitle: Text(
              workout.endedAt == null
                  ? 'Unfinished'
                  : workout.endedAt.toString(),
            ),
            // Add more workout details as needed
          ),
        );
      },
    );
  }
}

PreferredSizeWidget homeAppBar() {
  return AppBar(
    title: const Text('Home'),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Builder(
        builder: (BuildContext context) {
          final Color dividerColor = Theme.of(context).dividerColor;
          return Container(color: dividerColor, height: 1.0);
        },
      ),
    ),
  );
}
