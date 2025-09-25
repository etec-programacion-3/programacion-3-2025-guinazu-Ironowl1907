import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';

class RoutineProvider extends ChangeNotifier {
  late RoutineRepository routineRepo;
  late DatabaseService dbService;

  List<Routine> _routines = [];

  List<Routine> get workouts => _routines;

  RoutineProvider() {
    dbService = DatabaseService();
    dbService.initDB();

    routineRepo = RoutineRepository(dbService);
  }

  Future<void> load() async {
    _routines = await routineRepo.getAll();
    notifyListeners();
  }

  Future<void> add(Routine routine) async {
    if (await routineRepo.create(routine) == 0) {
      print("Error insering muscle group");
    }
    load();
  }

  Future<void> delete(Routine routine) async {
    if (await routineRepo.delete(routine.id!) == 0) {
      print("Error deleting muscle group");
    }
    load();
  }

  Future<void> update(Routine routine) async {
    if (await routineRepo.update(routine) == 0) {
      print("Error updating muscle group");
    }
    load();
  }
}
