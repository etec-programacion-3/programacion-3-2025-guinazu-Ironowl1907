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

  // ROUTINE CRUD
  Future<int> createRoutine(Routine routine) async {
    final db = await dbService.database;
    return await db.insert("routines", routine.toMap());
  }

  Future<Routine?> getRoutine(int id) async {
    final db = await dbService.database;
    final result = await db.query("routines", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Routine.fromMap(result.first) : null;
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await dbService.database;
    final result = await db.query("routines");
    return result.map((map) => Routine.fromMap(map)).toList();
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await dbService.database;
    return await db.update(
      "routines",
      routine.toMap(),
      where: "id = ?",
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await dbService.database;
    return await db.delete("routines", where: "id = ?", whereArgs: [id]);
  }
}
