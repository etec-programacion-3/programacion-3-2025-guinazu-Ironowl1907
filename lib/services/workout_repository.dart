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

  // WORKOUT CRUD
  Future<int> createWorkout(Workout workout) async {
    final db = await dbService.database;
    return await db.insert("workouts", workout.toMap());
  }

  Future<Workout?> getWorkout(int id) async {
    final db = await dbService.database;
    final result = await db.query("workouts", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Workout.fromMap(result.first) : null;
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await dbService.database;
    final result = await db.query("workouts", orderBy: "started_at DESC");
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<List<Workout>> getWorkoutsByRoutine(int routineId) async {
    final db = await dbService.database;
    final result = await db.query(
      "workouts",
      where: "routine_id = ?",
      whereArgs: [routineId],
      orderBy: "started_at DESC",
    );
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await dbService.database;
    return await db.update(
      "workouts",
      workout.toMap(),
      where: "id = ?",
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await dbService.database;
    return await db.delete("workouts", where: "id = ?", whereArgs: [id]);
  }
}
