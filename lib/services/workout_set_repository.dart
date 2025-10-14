import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutSetRepository {
  final DatabaseService dbService;
  WorkoutSetRepository(this.dbService);

  Future<int> create(WorkoutSet workoutSet) async {
    final Database db = dbService.db!;
    return await db.insert('workout_sets', workoutSet.toMap());
  }

  Future<WorkoutSet?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workout_sets',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? WorkoutSet.fromMap(result.first) : null;
  }

  Future<List<WorkoutSet>> getByExercise(int workoutExerciseId) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workout_sets',
      where: 'workout_exercise_id = ?',
      whereArgs: <Object?>[workoutExerciseId],
      orderBy: 'set_number ASC',
    );
    return result
        .map((Map<String, Object?> map) => WorkoutSet.fromMap(map))
        .toList();
  }

  Future<List<WorkoutSet>> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query('workout_sets');
    return result
        .map((Map<String, Object?> map) => WorkoutSet.fromMap(map))
        .toList();
  }

  Future<int> update(WorkoutSet workoutSet) async {
    final Database db = dbService.db!;
    return await db.update(
      'workout_sets',
      workoutSet.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[workoutSet.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> deleteByExercise(int workoutExerciseId) async {
    final Database db = dbService.db!;
    return await db.delete(
      'workout_sets',
      where: 'workout_exercise_id = ?',
      whereArgs: <Object?>[workoutExerciseId],
    );
  }
}
