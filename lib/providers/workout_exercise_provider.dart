import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';

class WorkoutExerciseProvider extends ChangeNotifier {
  late WorkoutExerciseRepository workoutExerciseRepo;
  late DatabaseService dbService;

  List<WorkoutExercise>? _currentWorkoutExercises;
  List<WorkoutExercise>? get workoutExercises => _currentWorkoutExercises;

  WorkoutExerciseProvider({required this.dbService}) {
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
  }

  Future<List<WorkoutExercise>> getByWorkout(int workoutId) async {
    return workoutExerciseRepo.getByWorkout(workoutId);
  }
}
