import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class RoutineRepository {
  final DatabaseService dbService;
  RoutineRepository(this.dbService);

  // ROUTINE CRUD
  Future<int> create(Routine routine) async {
    final db = await dbService.database;
    return await db.insert("routines", routine.toMap());
  }

  Future<Routine?> get(int id) async {
    final db = await dbService.database;
    final result = await db.query("routines", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Routine.fromMap(result.first) : null;
  }

  Future<List<Routine>> getAll() async {
    final db = await dbService.database;
    final result = await db.query("routines");
    return result.map((map) => Routine.fromMap(map)).toList();
  }

  Future<int> update(Routine routine) async {
    final db = await dbService.database;
    return await db.update(
      "routines",
      routine.toMap(),
      where: "id = ?",
      whereArgs: [routine.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbService.database;
    return await db.delete("routines", where: "id = ?", whereArgs: [id]);
  }
}
