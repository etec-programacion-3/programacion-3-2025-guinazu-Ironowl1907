import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';

class WorkoutExerciseProvider extends ChangeNotifier {
  late WorkoutExerciseRepository workoutExerciseRepo;
  late DatabaseService dbService;

  final List<MuscleGroup> _muscleGroup = <MuscleGroup>[];

  List<MuscleGroup> get workouts => _muscleGroup;

  WorkoutExerciseProvider({required this.dbService}) {
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
  }
}
