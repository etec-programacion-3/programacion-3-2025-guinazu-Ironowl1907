import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_exercise_repository.dart';

class RoutineExerciseProvider extends ChangeNotifier {
  late RoutineExerciseRepository routineRepo;
  late DatabaseService dbService;

  List<RoutineExercise>? _exercises = <RoutineExercise>[];

  List<RoutineExercise>? get exercise => _exercises;

  RoutineExerciseProvider({required this.dbService}) {
    routineRepo = RoutineExerciseRepository(dbService);
  }

  Future<void> load() async {
    _exercises = await routineRepo.getAll();
    notifyListeners();
  }

  Future<void> add(RoutineExercise routine) async {
    if (await routineRepo.create(routine) == 0) {
      print('Error insering muscle group');
    }
    load();
  }

  Future<void> delete(RoutineExercise routine) async {
    if (await routineRepo.delete(routine.id!) == 0) {
      print('Error deleting muscle group');
    }
    load();
  }

  Future<void> update(RoutineExercise routine) async {
    if (await routineRepo.update(routine) == 0) {
      print('Error updating muscle group');
    }
    load();
  }
}
