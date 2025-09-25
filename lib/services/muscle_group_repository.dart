import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class MuscleGroupRepository {
  final DatabaseService dbService;
  MuscleGroupRepository(this.dbService);

  Future<int> create(MuscleGroup muscleGroup) async {
    final Database db = dbService.db!;
    return db.insert("muscle_groups", muscleGroup.toMap());
  }

  Future<MuscleGroup?> get(int id) async {
    final Database db = dbService.db!;
    final result = await db.query(
      "muscle_groups",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? MuscleGroup.fromMap(result.first) : null;
  }

  Future<List<MuscleGroup>> getAll() async {
    final Database db = dbService.db!;
    final result = await db.query("muscle_groups");
    return result.map((map) => MuscleGroup.fromMap(map)).toList();
  }

  Future<int> update(MuscleGroup muscleGroup) async {
    final Database db = dbService.db!;
    return db.update(
      "muscle_groups",
      muscleGroup.toMap(),
      where: "id = ?",
      whereArgs: [muscleGroup.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = dbService.db!;
    return db.delete("muscle_groups", where: "id = ?", whereArgs: [id]);
  }
}
