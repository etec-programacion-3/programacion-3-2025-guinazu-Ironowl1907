import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutSetRepository {
  final DatabaseService dbService;
  WorkoutSetRepository(this.dbService);

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

  Future<int> createWorkoutSet(WorkoutSet workoutSet) async {
    final db = await dbService.database;
    return await db.insert("workout_sets", workoutSet.toMap());
  }

  Future<WorkoutSet?> getWorkoutSet(int id) async {
    final db = await dbService.database;
    final result = await db.query(
      "workout_sets",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? WorkoutSet.fromMap(result.first) : null;
  }

  Future<List<WorkoutSet>> getWorkoutSetsByExercise(
    int workoutExerciseId,
  ) async {
    final db = await dbService.database;
    final result = await db.query(
      "workout_sets",
      where: "workout_exercise_id = ?",
      whereArgs: [workoutExerciseId],
      orderBy: "set_number ASC",
    );
    return result.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  Future<List<WorkoutSet>> getAllWorkoutSets() async {
    final db = await dbService.database;
    final result = await db.query("workout_sets");
    return result.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  Future<int> updateWorkoutSet(WorkoutSet workoutSet) async {
    final db = await dbService.database;
    return await db.update(
      "workout_sets",
      workoutSet.toMap(),
      where: "id = ?",
      whereArgs: [workoutSet.id],
    );
  }

  Future<int> deleteWorkoutSet(int id) async {
    final db = await dbService.database;
    return await db.delete("workout_sets", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteWorkoutSetsByExercise(int workoutExerciseId) async {
    final db = await dbService.database;
    return await db.delete(
      "workout_sets",
      where: "workout_exercise_id = ?",
      whereArgs: [workoutExerciseId],
    );
  }
}
