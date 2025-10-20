import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutExerciseRepository {
  final DatabaseService dbService;
  WorkoutExerciseRepository(this.dbService);

  Future<int> create(WorkoutExercise workoutExercise) async {
    final Database db = dbService.db!;
    return await db.insert('workout_exercises', workoutExercise.toMap());
  }

  Future<WorkoutExercise?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? WorkoutExercise.fromMap(result.first) : null;
  }

  Future<List<WorkoutExercise>> getByWorkout(int workoutId) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workout_exercises',
      where: 'workout_id = ?',
      whereArgs: <Object?>[workoutId],
      orderBy: 'order_index ASC',
    );
    return result
        .map((Map<String, Object?> map) => WorkoutExercise.fromMap(map))
        .toList();
  }

  Future<List<WorkoutExercise>> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workout_exercises',
    );
    return result
        .map((Map<String, Object?> map) => WorkoutExercise.fromMap(map))
        .toList();
  }

  Future<int> update(WorkoutExercise workoutExercise) async {
    final Database db = dbService.db!;
    return await db.update(
      'workout_exercises',
      workoutExercise.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[workoutExercise.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      'workout_exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> deleteByWorkout(int workoutId) async {
    final Database db = dbService.db!;
    return await db.delete(
      'workout_exercises',
      where: 'workout_id = ?',
      whereArgs: <Object?>[workoutId],
    );
  }

  Future<List<DetailedWorkoutExercise>> getDetailedWorkoutExercisesByWorkout(
    int workoutId,
  ) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
    SELECT 
      we.id as we_id,
      we.workout_id,
      we.exercise_id,
      we.order_index,
      we.sets,
      we.reps,
      e.id as e_id,
      e.name as e_name,
      e.description as e_description,
      e.muscle_group_id
    FROM workout_exercises we
    JOIN exercises e ON we.exercise_id = e.id
    WHERE we.workout_id = ?
    ORDER BY we.order_index ASC
    ''',
      <Object?>[workoutId],
    );

    return result.map((Map<String, Object?> row) {
      final Exercise exercise = Exercise(
        id: row['e_id'] as int?,
        name: row['e_name'] as String,
        description: row['e_description'] as String?,
        muscleGroupId: row['muscle_group_id'] as int?,
      );

      final WorkoutExercise workoutExercise = WorkoutExercise(
        id: row['we_id'] as int?,
        workoutId: row['workout_id'] as int,
        exerciseId: row['exercise_id'] as int,
        orderIndex: row['order_index'] as int,
        sets: row['sets'] as int,
        reps: row['reps'] as int,
      );

      return DetailedWorkoutExercise(exercise, workoutExercise);
    }).toList();
  }
}
