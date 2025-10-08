import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class RoutineRepository {
  final DatabaseService dbService;
  RoutineRepository(this.dbService);

  // ROUTINE CRUD
  Future<int> create(Routine routine) async {
    final Database db = dbService.db!;
    return await db.insert('routines', routine.toMap());
  }

  Future<Routine?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'routines',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? Routine.fromMap(result.first) : null;
  }

  Future<List<Routine>> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query('routines');
    return result
        .map((Map<String, Object?> map) => Routine.fromMap(map))
        .toList();
  }

  Future<int> update(Routine routine) async {
    final Database db = dbService.db!;
    return await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[routine.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<List<DetailedRoutineExercise>> getDetailedRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final Database db = dbService.db!;

    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT 
        re.id as re_id,
        re.routine_id,
        re.exercise_id,
        re.`order`,
        re.sets,
        re.reps,
        re.rest_seconds,
        e.id as e_id,
        e.name as e_name,
        e.description as e_description,
        e.muscle_group_id
      FROM routine_exercises re
      JOIN exercises e ON re.exercise_id = e.id
      WHERE re.routine_id = ?
      ORDER BY re.`order` ASC
      ''',
      <Object?>[routineId],
    );

    return result.map((Map<String, Object?> row) {
      final Exercise exercise = Exercise(
        id: row['e_id'] as int?,
        name: row['e_name'] as String,
        description: row['e_description'] as String?,
        muscleGroupId: row['muscle_group_id'] as int?,
      );

      final RoutineExercise routineExercise = RoutineExercise(
        id: row['re_id'] as int?,
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
