import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class ExerciseRepository {
  final DatabaseService dbService;
  ExerciseRepository(this.dbService);

  Future<int> create(Exercise exercise) async {
    final Database db = dbService.db!;
    return db.insert('exercises', exercise.toMap());
  }

  Future<Exercise?> get(int id) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isNotEmpty ? Exercise.fromMap(result.first) : null;
  }

  Future<List<Exercise>> getAll() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query('exercises');
    return result
        .map((Map<String, Object?> map) => Exercise.fromMap(map))
        .toList();
  }

  Future<List<Exercise>> getByMuscleGroup(int muscleGroupId) async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'exercises',
      where: 'muscle_group_id = ?',
      whereArgs: <Object?>[muscleGroupId],
    );
    return result
        .map((Map<String, Object?> map) => Exercise.fromMap(map))
        .toList();
  }

  Future<int> update(Exercise exercise) async {
    final Database db = dbService.db!;
    return db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[exercise.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return db.delete('exercises', where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
