import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/widgets/workout_routine_card.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RoutineProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoutineProvider, WorkoutProvider>(
      builder:
          (
            BuildContext context,
            RoutineProvider routineProvider,
            WorkoutProvider workoutProvier,
            _,
          ) {
            return ListView.builder(
              itemCount: routineProvider.routines.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: WorkoutRoutineCard(
                    routine: routineProvider.routines[index],
                  ),
                );
              },
            );
          },
    );
  }
}

PreferredSizeWidget workoutAppBar() {
  return AppBar(
    title: const Text('Workout'),
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
