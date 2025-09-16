import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_logger/models/models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master.db");
    print("Searching for Db on: $databasePath");
    return await openDatabase(databasePath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating database tables...");
    for (String query in DatabaseSchema.getAllCreateTableQueries()) {
      await db.execute(query);
      print("Executed: ${query.split('(')[0].trim()}"); // Log table creation
    }
    print("Database tables created successfully");
  }

  Future<void> closeDatabase() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  Future<void> deleteDB() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master.db");
    await deleteDatabase(databasePath);
    _db = null;
  }

  // MUSCLE GROUP CRUD
  Future<int> createMuscleGroup(MuscleGroup muscleGroup) async {
    final db = await database;
    return await db.insert("muscle_groups", muscleGroup.toMap());
  }

  Future<MuscleGroup?> getMuscleGroup(int id) async {
    final db = await database;
    final result = await db.query(
      "muscle_groups",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? MuscleGroup.fromMap(result.first) : null;
  }

  Future<List<MuscleGroup>> getAllMuscleGroups() async {
    final db = await database;
    final result = await db.query("muscle_groups");
    return result.map((map) => MuscleGroup.fromMap(map)).toList();
  }

  Future<int> updateMuscleGroup(MuscleGroup muscleGroup) async {
    final db = await database;
    return await db.update(
      "muscle_groups",
      muscleGroup.toMap(),
      where: "id = ?",
      whereArgs: [muscleGroup.id],
    );
  }

  Future<int> deleteMuscleGroup(int id) async {
    final db = await database;
    return await db.delete("muscle_groups", where: "id = ?", whereArgs: [id]);
  }

  // EXERCISE CRUD
  Future<int> createExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert("exercises", exercise.toMap());
  }

  Future<Exercise?> getExercise(int id) async {
    final db = await database;
    final result = await db.query(
      "exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? Exercise.fromMap(result.first) : null;
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final result = await db.query("exercises");
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(int muscleGroupId) async {
    final db = await database;
    final result = await db.query(
      "exercises",
      where: "muscle_group_id = ?",
      whereArgs: [muscleGroupId],
    );
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      "exercises",
      exercise.toMap(),
      where: "id = ?",
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete("exercises", where: "id = ?", whereArgs: [id]);
  }

  // ROUTINE CRUD
  Future<int> createRoutine(Routine routine) async {
    final db = await database;
    return await db.insert("routines", routine.toMap());
  }

  Future<Routine?> getRoutine(int id) async {
    final db = await database;
    final result = await db.query("routines", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Routine.fromMap(result.first) : null;
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    final result = await db.query("routines");
    return result.map((map) => Routine.fromMap(map)).toList();
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    return await db.update(
      "routines",
      routine.toMap(),
      where: "id = ?",
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete("routines", where: "id = ?", whereArgs: [id]);
  }

  // ROUTINE EXERCISE CRUD
  Future<int> createRoutineExercise(RoutineExercise routineExercise) async {
    final db = await database;
    return await db.insert("routine_exercises", routineExercise.toMap());
  }

  Future<RoutineExercise?> getRoutineExercise(int id) async {
    final db = await database;
    final result = await db.query(
      "routine_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty ? RoutineExercise.fromMap(result.first) : null;
  }

  Future<List<RoutineExercise>> getRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final db = await database;
    final result = await db.query(
      "routine_exercises",
      where: "routine_id = ?",
      whereArgs: [routineId],
      orderBy: "`order` ASC",
    );
    return result.map((map) => RoutineExercise.fromMap(map)).toList();
  }

  Future<List<RoutineExercise>> getAllRoutineExercises() async {
    final db = await database;
    final result = await db.query("routine_exercises");
    return result.map((map) => RoutineExercise.fromMap(map)).toList();
  }

  Future<int> updateRoutineExercise(RoutineExercise routineExercise) async {
    final db = await database;
    return await db.update(
      "routine_exercises",
      routineExercise.toMap(),
      where: "id = ?",
      whereArgs: [routineExercise.id],
    );
  }

  Future<int> deleteRoutineExercise(int id) async {
    final db = await database;
    return await db.delete(
      "routine_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteRoutineExercisesByRoutine(int routineId) async {
    final db = await database;
    return await db.delete(
      "routine_exercises",
      where: "routine_id = ?",
      whereArgs: [routineId],
    );
  }

  // WORKOUT CRUD
  Future<int> createWorkout(Workout workout) async {
    final db = await database;
    return await db.insert("workouts", workout.toMap());
  }

  Future<Workout?> getWorkout(int id) async {
    final db = await database;
    final result = await db.query("workouts", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Workout.fromMap(result.first) : null;
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final result = await db.query("workouts", orderBy: "started_at DESC");
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<List<Workout>> getWorkoutsByRoutine(int routineId) async {
    final db = await database;
    final result = await db.query(
      "workouts",
      where: "routine_id = ?",
      whereArgs: [routineId],
      orderBy: "started_at DESC",
    );
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    return await db.update(
      "workouts",
      workout.toMap(),
      where: "id = ?",
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete("workouts", where: "id = ?", whereArgs: [id]);
  }

  // WORKOUT EXERCISE CRUD
  Future<int> createWorkoutExercise(WorkoutExercise workoutExercise) async {
    final db = await database;
    return await db.insert("workout_exercises", workoutExercise.toMap());
  }

  Future<WorkoutExercise?> getWorkoutExercise(int id) async {
    final db = await database;
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
    final db = await database;
    final result = await db.query(
      "workout_exercises",
      where: "workout_id = ?",
      whereArgs: [workoutId],
      orderBy: "order_index ASC",
    );
    return result.map((map) => WorkoutExercise.fromMap(map)).toList();
  }

  Future<List<WorkoutExercise>> getAllWorkoutExercises() async {
    final db = await database;
    final result = await db.query("workout_exercises");
    return result.map((map) => WorkoutExercise.fromMap(map)).toList();
  }

  Future<int> updateWorkoutExercise(WorkoutExercise workoutExercise) async {
    final db = await database;
    return await db.update(
      "workout_exercises",
      workoutExercise.toMap(),
      where: "id = ?",
      whereArgs: [workoutExercise.id],
    );
  }

  Future<int> deleteWorkoutExercise(int id) async {
    final db = await database;
    return await db.delete(
      "workout_exercises",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteWorkoutExercisesByWorkout(int workoutId) async {
    final db = await database;
    return await db.delete(
      "workout_exercises",
      where: "workout_id = ?",
      whereArgs: [workoutId],
    );
  }

  Future<Workout> getUnfinishedWorkout() async {
    final db = await database;
    var result = await db.query(
      "workouts",
      where: "ended_at == NULL",
      limit: 1,
    );
    return Workout.fromMap(result[0]);
  }

  // WORKOUT SET CRUD
  Future<int> createWorkoutSet(WorkoutSet workoutSet) async {
    final db = await database;
    return await db.insert("workout_sets", workoutSet.toMap());
  }

  Future<WorkoutSet?> getWorkoutSet(int id) async {
    final db = await database;
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
    final db = await database;
    final result = await db.query(
      "workout_sets",
      where: "workout_exercise_id = ?",
      whereArgs: [workoutExerciseId],
      orderBy: "set_number ASC",
    );
    return result.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  Future<List<WorkoutSet>> getAllWorkoutSets() async {
    final db = await database;
    final result = await db.query("workout_sets");
    return result.map((map) => WorkoutSet.fromMap(map)).toList();
  }

  Future<int> updateWorkoutSet(WorkoutSet workoutSet) async {
    final db = await database;
    return await db.update(
      "workout_sets",
      workoutSet.toMap(),
      where: "id = ?",
      whereArgs: [workoutSet.id],
    );
  }

  Future<int> deleteWorkoutSet(int id) async {
    final db = await database;
    return await db.delete("workout_sets", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteWorkoutSetsByExercise(int workoutExerciseId) async {
    final db = await database;
    return await db.delete(
      "workout_sets",
      where: "workout_exercise_id = ?",
      whereArgs: [workoutExerciseId],
    );
  }
}
