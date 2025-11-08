import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

Widget muscleGroupChip(BuildContext context, Exercise exercise) {
  final MuscleGroupProvider muscleGroupProvider = context
      .watch<MuscleGroupProvider>();
  return FutureBuilder<MuscleGroup?>(
    future: muscleGroupProvider.get(exercise.muscleGroupId ?? 0),
    builder: (BuildContext context, AsyncSnapshot<MuscleGroup?> asyncSnapshot) {
      String label;
      if (asyncSnapshot.connectionState == ConnectionState.waiting) {
        label = 'Loading...';
      } else if (asyncSnapshot.hasError) {
        label = 'Error';
      } else if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
        label = asyncSnapshot.data!.name;
      } else {
        label = 'None';
      }

      return Chip(label: Text(label));
    },
  );
}
