import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_set_repository.dart';

class WorkoutSetProvider extends ChangeNotifier {
  late WorkoutSetRepository workoutSetRepo;
  late DatabaseService dbService;

  final List<MuscleGroup> _muscleGroup = <MuscleGroup>[];

  List<MuscleGroup> get workouts => _muscleGroup;

  WorkoutSetProvider({required this.dbService}) {
    workoutSetRepo = WorkoutSetRepository(dbService);
  }
}
