import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class RoutineExerciseRepository {
  final DatabaseService dbService;
  RoutineExerciseRepository(this.dbService);

  Future<RoutineExercise?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'routine_exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? RoutineExercise.fromMap(result.first) : null;
  }

  Future<List<RoutineExercise>?> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'routine_exercises',
    );

    return result.isNotEmpty
        ? result
              .map((Map<String, Object?> map) => RoutineExercise.fromMap(map))
              .toList()
        : null;
  }

  Future<int> create(RoutineExercise routineExercise) async {
    print("Creating routine exercise ${routineExercise.toMap()}");
    final Database db = dbService.db!;
    return await db.insert('routine_exercises', routineExercise.toMap());
  }

  Future<DetailedRoutineExercise?> getDetailedRoutineExercise(int id) async {
    final Database db = dbService.db!;

    final List<Map<String, Object?>> routineExerciseResult = await db.query(
      'routine_exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );

    if (routineExerciseResult.isEmpty) {
      return null;
    }

    final RoutineExercise routineExercise = RoutineExercise.fromMap(
      routineExerciseResult.first,
    );

    final List<Map<String, Object?>> exerciseResult = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: <Object?>[routineExercise.exerciseId],
    );

    if (exerciseResult.isEmpty) {
      return null;
    }

    final Exercise exercise = Exercise.fromMap(exerciseResult.first);

    return DetailedRoutineExercise(exercise, routineExercise);
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

  Future<List<RoutineExercise>> getRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: <Object?>[routineId],
      orderBy: '`order` ASC',
    );
    return result
        .map((Map<String, Object?> map) => RoutineExercise.fromMap(map))
        .toList();
  }

  Future<Exercise> getExerciseFromRoutineExercise(
    RoutineExercise rExercise,
  ) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: <Object?>[rExercise.exerciseId],
    );
    return Exercise.fromMap(result.first);
  }

  Future<int> update(RoutineExercise routineExercise) async {
    final Database db = dbService.db!;
    return await db.update(
      'routine_exercises',
      routineExercise.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[routineExercise.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      'routine_exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> deleteByRoutine(int routineId) async {
    final Database db = dbService.db!;
    return await db.delete(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: <Object?>[routineId],
    );
  }
}
