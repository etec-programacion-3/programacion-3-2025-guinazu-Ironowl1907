import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutRepository {
  final DatabaseService dbService;
  WorkoutRepository(this.dbService);

  Future<int> createWorkout(Workout workout) async {
    final Database db = dbService.db!;
    return await db.insert('workouts', workout.toMap());
  }

  Future<Workout?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? Workout.fromMap(result.first) : null;
  }

  Future<List<Workout>> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workouts',
      orderBy: 'started_at DESC',
    );
    return result
        .map((Map<String, Object?> map) => Workout.fromMap(map))
        .toList();
  }

  Future<List<Workout>> getByRoutine(int routineId) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workouts',
      where: 'routine_id = ?',
      whereArgs: <Object?>[routineId],
      orderBy: 'started_at DESC',
    );
    return result
        .map((Map<String, Object?> map) => Workout.fromMap(map))
        .toList();
  }

  Future<int> update(Workout workout) async {
    final Database db = dbService.db!;
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[workout.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
