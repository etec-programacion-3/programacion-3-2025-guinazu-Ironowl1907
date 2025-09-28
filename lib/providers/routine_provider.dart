import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';

class RoutineProvider extends ChangeNotifier {
  late RoutineRepository routineRepo;
  late DatabaseService dbService;

  List<Routine> _routines = <Routine>[];

  List<Routine> get routines => _routines;

  RoutineProvider({required this.dbService}) {
    routineRepo = RoutineRepository(dbService);
  }

  Future<void> load() async {
    _routines = await routineRepo.getAll();
    notifyListeners();
  }

  Future<void> add(Routine routine) async {
    if (await routineRepo.create(routine) == 0) {
      print('Error insering muscle group');
    }
    load();
  }

  Future<void> delete(Routine routine) async {
    if (await routineRepo.delete(routine.id!) == 0) {
      print('Error deleting muscle group');
    }
    load();
  }

  Future<void> update(Routine routine) async {
    if (await routineRepo.update(routine) == 0) {
      print('Error updating muscle group');
    }
    load();
  }

  Future<List<DetailedRoutineExercise>> getDetailedRoutineExercisesByRoutine(
    Routine routine,
  ) async {
    final Database db = dbService.db!;

    final List<Map<String, Object?>> results = await db.rawQuery(
      '''
    SELECT 
      e.id as exercise_id,
      e.name as exercise_name,
      e.description as exercise_description,
      e.muscle_group_id as exercise_muscle_group_id,
      re.id as routine_exercise_id,
      re.routine_id,
      re.exercise_id,
      re.`order`,
      re.sets,
      re.reps,
      re.rest_seconds
    FROM routine_exercises re
    INNER JOIN exercises e ON re.exercise_id = e.id
    WHERE re.routine_id = ?
    ORDER BY re.`order` ASC
  ''',
      <int?>[routine.id],
    );

    return results.map((Map<String, Object?> row) {
      final Exercise exercise = Exercise(
        id: row['exercise_id'] as int?,
        name: row['exercise_name'] as String,
        description: row['exercise_description'] as String?,
        muscleGroupId: row['exercise_muscle_group_id'] as int?,
      );

      final RoutineExercise routineExercise = RoutineExercise(
        id: row['routine_exercise_id'] as int?,
        routineId: row['routine_id'] as int,
        exerciseId: row['exercise_id'] as int,
        order: row['order'] as int,
        sets: row['sets'] as int?,
        reps: row['reps'] as int?,
        restSeconds: row['rest_seconds'] as int?,
      );

      return DetailedRoutineExercise(exercise, routineExercise);
    }).toList();
  }
}
