import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class ExerciseRepository {
  final DatabaseService dbService;
  ExerciseRepository(this.dbService);

  Future<int> create(Exercise exercise) async {
    final db = await dbService.database;
    return db.insert("exercises", exercise.toMap());
  }

  Future<Exercise?> get(int id) async {
    final db = await dbService.database;
    final result = await db.query(
      "exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? Exercise.fromMap(result.first) : null;
  }

  // ROUTINE EXERCISE CRUD
  Future<int> createRoutineExercise(RoutineExercise routineExercise) async {
    final db = await dbService.database;
    return await db.insert("routine_exercises", routineExercise.toMap());
  }

  Future<DetailedRoutineExercise?> getDetailedRoutineExercise(int id) async {
    final db = await dbService.database;

    // Get the routine exercise first
    final routineExerciseResult = await db.query(
      "routine_exercises",
      where: "id = ?",
      whereArgs: [id],
    );

    if (routineExerciseResult.isEmpty) {
      return null;
    }

    final routineExercise = RoutineExercise.fromMap(
      routineExerciseResult.first,
    );

    // Get the associated exercise
    final exerciseResult = await db.query(
      "exercises",
      where: "id = ?",
      whereArgs: [routineExercise.exerciseId],
    );

    if (exerciseResult.isEmpty) {
      return null;
    }

    final exercise = Exercise.fromMap(exerciseResult.first);

    return DetailedRoutineExercise(exercise, routineExercise);
  }

  // Get all detailed routine exercises for a specific routine
  Future<List<DetailedRoutineExercise>> getDetailedRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final db = await dbService.database;

    final result = await db.rawQuery(
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
      [routineId],
    );

    return result.map((row) {
      final exercise = Exercise(
        id: row['e_id'] as int?,
        name: row['e_name'] as String,
        description: row['e_description'] as String?,
        muscleGroupId: row['muscle_group_id'] as int?,
      );

      final routineExercise = RoutineExercise(
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

  Future<RoutineExercise?> getRoutineExercise(int id) async {
    final db = await dbService.database;
    final result = await db.query(
      "routine_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? RoutineExercise.fromMap(result.first) : null;
  }

  Future<List<RoutineExercise>> getRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final db = await dbService.database;
    final result = await db.query(
      "routine_exercises",
      where: "routine_id = ?",
      whereArgs: [routineId],
      orderBy: "`order` ASC",
    );
    return result.map((map) => RoutineExercise.fromMap(map)).toList();
  }

  Future<List<RoutineExercise>> getAllRoutineExercises() async {
    final db = await dbService.database;
    final result = await db.query("routine_exercises");
    return result.map((map) => RoutineExercise.fromMap(map)).toList();
  }

  Future<int> updateRoutineExercise(RoutineExercise routineExercise) async {
    final db = await dbService.database;
    return await db.update(
      "routine_exercises",
      routineExercise.toMap(),
      where: "id = ?",
      whereArgs: [routineExercise.id],
    );
  }

  Future<int> deleteRoutineExercise(int id) async {
    final db = await dbService.database;
    return await db.delete(
      "routine_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteRoutineExercisesByRoutine(int routineId) async {
    final db = await dbService.database;
    return await db.delete(
      "routine_exercises",
      where: "routine_id = ?",
      whereArgs: [routineId],
    );
  }
}
