import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class WorkoutExerciseRepository {
  final DatabaseService dbService;
  WorkoutExerciseRepository(this.dbService);

  Future<int> create(Exercise exercise) async {
    final Database db = dbService.db!;
    return db.insert("exercises", exercise.toMap());
  }

  Future<Exercise?> get(int id) async {
    final Database db = dbService.db!;
    final result = await db.query(
      "exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? Exercise.fromMap(result.first) : null;
  }

  // WORKOUT EXERCISE CRUD
  Future<int> createWorkoutExercise(WorkoutExercise workoutExercise) async {
    final Database db = dbService.db!;
    return await db.insert("workout_exercises", workoutExercise.toMap());
  }

  Future<WorkoutExercise?> getWorkoutExercise(int id) async {
    final Database db = dbService.db!;
    final result = await db.query(
      "workout_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? WorkoutExercise.fromMap(result.first) : null;
  }

  Future<List<WorkoutExercise>> getWorkoutExercisesByWorkout(
    int workoutId,
  ) async {
    final Database db = dbService.db!;
    final result = await db.query(
      "workout_exercises",
      where: "workout_id = ?",
      whereArgs: [workoutId],
      orderBy: "order_index ASC",
    );
    return result.map((map) => WorkoutExercise.fromMap(map)).toList();
  }

  Future<List<WorkoutExercise>> getAllWorkoutExercises() async {
    final Database db = dbService.db!;
    final result = await db.query("workout_exercises");
    return result.map((map) => WorkoutExercise.fromMap(map)).toList();
  }

  Future<int> updateWorkoutExercise(WorkoutExercise workoutExercise) async {
    final Database db = dbService.db!;
    return await db.update(
      "workout_exercises",
      workoutExercise.toMap(),
      where: "id = ?",
      whereArgs: [workoutExercise.id],
    );
  }

  Future<int> deleteWorkoutExercise(int id) async {
    final Database db = dbService.db!;
    return await db.delete(
      "workout_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteWorkoutExercisesByWorkout(int workoutId) async {
    final Database db = dbService.db!;
    return await db.delete(
      "workout_exercises",
      where: "workout_id = ?",
      whereArgs: [workoutId],
    );
  }

  Future<Workout?> getUnfinishedWorkout() async {
    final Database db = dbService.db!;
    var result = await db.query(
      "workouts",
      where: "ended_at IS NULL",
      orderBy: "started_at DESC", // Get most recent
      limit: 1,
    );
    if (result.isEmpty) return null;

    final workout = Workout.fromMap(result[0]);
    return workout;
  }
}
