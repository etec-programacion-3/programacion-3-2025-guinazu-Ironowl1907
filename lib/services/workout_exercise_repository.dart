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
}
