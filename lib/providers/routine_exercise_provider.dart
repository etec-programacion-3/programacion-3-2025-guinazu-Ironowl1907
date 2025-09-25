import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_exercise_repository.dart';

class RoutineExerciseProvider extends ChangeNotifier {
  late RoutineExerciseRepository routineRepo;
  late DatabaseService dbService;

  List<RoutineExercise> _routines = [];

  List<RoutineExercise> get workouts => _routines;

  RoutineExerciseProvider() {
    dbService = DatabaseService();
    dbService.initDB();

    routineRepo = RoutineExerciseRepository(dbService);
  }
}
