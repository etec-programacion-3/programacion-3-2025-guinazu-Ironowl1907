import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  late ExerciseRepository exerciseRepo;
  late DatabaseService dbService;

  List<Exercise> _exercises = [];

  List<Exercise> get exercises => _exercises;

  ExerciseProvider({required this.dbService}) {
    exerciseRepo = ExerciseRepository(dbService);
  }

  Future<void> load() async {
    _exercises = await exerciseRepo.getAll();
    notifyListeners();
  }

  Future<void> add(Exercise exer) async {
    if (await exerciseRepo.create(exer) == 0) {
      print("Error insering muscle group");
    }
    load();
  }

  Future<void> delete(Exercise exer) async {
    if (await exerciseRepo.delete(exer.id!) == 0) {
      print("Error deleting muscle group");
    }
    load();
  }

  Future<void> update(Exercise exer) async {
    if (await exerciseRepo.update(exer) == 0) {
      print("Error updating muscle group");
    }
    load();
  }

  Future<Exercise> getFromRoutineExercise(RoutineExercise rExercise) async {
    return exerciseRepo.getFromRoutineExercise(rExercise);
  }
}
