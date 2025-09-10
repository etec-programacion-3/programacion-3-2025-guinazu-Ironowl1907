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
    // Execute each table creation query
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

  // ==================== MUSCLE GROUP CRUD ====================

  Future<int> insertMuscleGroup(MuscleGroup muscleGroup) async {
    final db = await database;
    return await db.insert('muscle_groups', muscleGroup.toMap());
  }

  Future<List<MuscleGroup>> getAllMuscleGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('muscle_groups');
    return List.generate(maps.length, (i) => MuscleGroup.fromMap(maps[i]));
  }

  Future<MuscleGroup?> getMuscleGroupById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'muscle_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MuscleGroup.fromMap(maps.first);
  }

  Future<int> updateMuscleGroup(MuscleGroup muscleGroup) async {
    final db = await database;
    return await db.update(
      'muscle_groups',
      muscleGroup.toMap(),
      where: 'id = ?',
      whereArgs: [muscleGroup.id],
    );
  }

  Future<int> deleteMuscleGroup(int id) async {
    final db = await database;
    return await db.delete('muscle_groups', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== EXERCISE CRUD ====================

  Future<int> insertExercise(Exercise exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise.toMap());
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<Exercise?> getExerciseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Exercise.fromMap(maps.first);
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(int muscleGroupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'muscle_group_id = ?',
      whereArgs: [muscleGroupId],
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await database;
    return await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ROUTINE CRUD ====================

  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    return await db.insert('routines', routine.toMap());
  }

  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return List.generate(maps.length, (i) => Routine.fromMap(maps[i]));
  }

  Future<Routine?> getRoutineById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Routine.fromMap(maps.first);
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    return await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(int id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ROUTINE EXERCISE CRUD ====================

  Future<int> insertRoutineExercise(RoutineExercise routineExercise) async {
    final db = await database;
    return await db.insert('routine_exercises', routineExercise.toMap());
  }

  Future<List<RoutineExercise>> getAllRoutineExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routine_exercises');
    return List.generate(maps.length, (i) => RoutineExercise.fromMap(maps[i]));
  }

  Future<List<Exercise>> getAllExercisesFromRoutine(int routineId) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
    SELECT e.* FROM exercises e
    JOIN routine_exercises re ON e.id = re.exercise_id
    WHERE re.routine_id = ?
  ''',
      [routineId],
    );
    return List.generate(maps.length, (i) => Exercise.fromMap(maps[i]));
  }

  Future<RoutineExercise?> getRoutineExerciseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routine_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return RoutineExercise.fromMap(maps.first);
  }

  Future<List<RoutineExercise>> getRoutineExercisesByRoutine(
    int routineId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: [routineId],
    );
    return List.generate(maps.length, (i) => RoutineExercise.fromMap(maps[i]));
  }

  Future<int> updateRoutineExercise(RoutineExercise routineExercise) async {
    final db = await database;
    return await db.update(
      'routine_exercises',
      routineExercise.toMap(),
      where: 'id = ?',
      whereArgs: [routineExercise.id],
    );
  }

  Future<int> deleteRoutineExercise(int id) async {
    final db = await database;
    return await db.delete(
      'routine_exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRoutineExercisesByRoutine(int routineId) async {
    final db = await database;
    return await db.delete(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: [routineId],
    );
  }

  // ==================== WORKOUT CRUD ====================

  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<Workout?> getWorkoutById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Workout.fromMap(maps.first);
  }

  Future<List<Workout>> getWorkoutsByRoutine(int routineId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'routine_id = ?',
      whereArgs: [routineId],
    );
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'started_at >= ? AND started_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'started_at DESC',
    );
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    return await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== WORKOUT LOG CRUD ====================

  Future<int> insertWorkoutLog(WorkoutLog workoutLog) async {
    final db = await database;
    return await db.insert('workout_logs', workoutLog.toMap());
  }

  Future<List<WorkoutLog>> getAllWorkoutLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workout_logs');
    return List.generate(maps.length, (i) => WorkoutLog.fromMap(maps[i]));
  }

  Future<WorkoutLog?> getWorkoutLogById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WorkoutLog.fromMap(maps.first);
  }

  Future<List<WorkoutLog>> getWorkoutLogsByWorkout(int workoutId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_logs',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'set_number ASC',
    );
    return List.generate(maps.length, (i) => WorkoutLog.fromMap(maps[i]));
  }

  Future<List<WorkoutLog>> getWorkoutLogsByExercise(int exerciseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workout_logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
    return List.generate(maps.length, (i) => WorkoutLog.fromMap(maps[i]));
  }

  Future<int> updateWorkoutLog(WorkoutLog workoutLog) async {
    final db = await database;
    return await db.update(
      'workout_logs',
      workoutLog.toMap(),
      where: 'id = ?',
      whereArgs: [workoutLog.id],
    );
  }

  Future<int> deleteWorkoutLog(int id) async {
    final db = await database;
    return await db.delete('workout_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWorkoutLogsByWorkout(int workoutId) async {
    final db = await database;
    return await db.delete(
      'workout_logs',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  // ==================== UTILITY METHODS ====================

  /// Get complete routine with exercises
  Future<Map<String, dynamic>?> getRoutineWithExercises(int routineId) async {
    final routine = await getRoutineById(routineId);
    if (routine == null) return null;

    final routineExercises = await getRoutineExercisesByRoutine(routineId);
    final List<Map<String, dynamic>> exerciseDetails = [];

    for (final routineExercise in routineExercises) {
      final exercise = await getExerciseById(routineExercise.exerciseId);
      if (exercise != null) {
        exerciseDetails.add({
          'routine_exercise': routineExercise,
          'exercise': exercise,
        });
      }
    }

    return {'routine': routine, 'exercises': exerciseDetails};
  }

  /// Get workout with all logs
  Future<Map<String, dynamic>?> getWorkoutWithLogs(int workoutId) async {
    final workout = await getWorkoutById(workoutId);
    if (workout == null) return null;

    final logs = await getWorkoutLogsByWorkout(workoutId);

    return {'workout': workout, 'logs': logs};
  }

  /// Get exercise progress (all workout logs for an exercise)
  Future<List<WorkoutLog>> getExerciseProgress(int exerciseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT wl.* FROM workout_logs wl
      JOIN workouts w ON wl.workout_id = w.id
      WHERE wl.exercise_id = ?
      ORDER BY w.started_at DESC, wl.set_number ASC
    ''',
      [exerciseId],
    );

    return List.generate(maps.length, (i) => WorkoutLog.fromMap(maps[i]));
  }

  /// Get recent workouts (last N workouts)
  Future<List<Workout>> getRecentWorkouts(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Workout.fromMap(maps[i]));
  }

  /// Start a new workout
  Future<int> startWorkout(int routineId) async {
    final workout = Workout(routineId: routineId, startedAt: DateTime.now());
    return await insertWorkout(workout);
  }

  /// End a workout
  Future<int> endWorkout(int workoutId) async {
    final workout = await getWorkoutById(workoutId);
    if (workout == null) return 0;

    workout.endedAt = DateTime.now();
    return await updateWorkout(workout);
  }

  /// Batch insert workout logs for a set
  Future<List<int>> insertWorkoutSet(
    int workoutId,
    int exerciseId,
    List<Map<String, dynamic>> sets,
  ) async {
    final List<int> insertedIds = [];

    for (int i = 0; i < sets.length; i++) {
      final set = sets[i];
      final workoutLog = WorkoutLog(
        workoutId: workoutId,
        exerciseId: exerciseId,
        setNumber: i + 1,
        reps: set['reps'],
        weightKg: set['weight']?.toDouble(),
        restSeconds: set['rest'],
      );

      final id = await insertWorkoutLog(workoutLog);
      insertedIds.add(id);
    }

    return insertedIds;
  }
}
