import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(
      builder: (context, muscleGroupProvider, child) {
        return ListView.builder(itemBuilder: (context, index) {});
      },
    );
  }
}
