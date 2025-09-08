// MuscleGroup class
class MuscleGroup {
  int? id;
  String name;

  MuscleGroup({this.id, required this.name});

  // Getters
  int? get getId => id;
  String get getName => name;

  // Setters
  set setId(int? id) => this.id = id;
  set setName(String name) => this.name = name;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Create from Map
  factory MuscleGroup.fromMap(Map<String, dynamic> map) {
    return MuscleGroup(id: map['id'], name: map['name']);
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE muscle_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL
      );
    ''';
  }
}

// Exercise class
class Exercise {
  int? id;
  String name;
  String? description;
  int? muscleGroupId;

  Exercise({this.id, required this.name, this.description, this.muscleGroupId});

  // Getters
  int? get getId => id;
  String get getName => name;
  String? get getDescription => description;
  int? get getMuscleGroupId => muscleGroupId;

  // Setters
  set setId(int? id) => this.id = id;
  set setName(String name) => this.name = name;
  set setDescription(String? description) => this.description = description;
  set setMuscleGroupId(int? muscleGroupId) =>
      this.muscleGroupId = muscleGroupId;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscle_group_id': muscleGroupId,
    };
  }

  // Create from Map
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      muscleGroupId: map['muscle_group_id'],
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        description TEXT,
        muscle_group_id INTEGER,
        FOREIGN KEY(muscle_group_id) REFERENCES muscle_groups(id)
      );
    ''';
  }
}

// Routine class
class Routine {
  int? id;
  String name;
  String? description;
  DateTime? createdAt;

  Routine({this.id, required this.name, this.description, this.createdAt});

  // Getters
  int? get getId => id;
  String get getName => name;
  String? get getDescription => description;
  DateTime? get getCreatedAt => createdAt;

  // Setters
  set setId(int? id) => this.id = id;
  set setName(String name) => this.name = name;
  set setDescription(String? description) => this.description = description;
  set setCreatedAt(DateTime? createdAt) => this.createdAt = createdAt;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';
  }
}

// RoutineExercise class
class RoutineExercise {
  int? id;
  int routineId;
  int exerciseId;
  int? sets;
  int? reps;
  int? restSeconds;

  RoutineExercise({
    this.id,
    required this.routineId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.restSeconds,
  });

  // Getters
  int? get getId => id;
  int get getRoutineId => routineId;
  int get getExerciseId => exerciseId;
  int? get getSets => sets;
  int? get getReps => reps;
  int? get getRestSeconds => restSeconds;

  // Setters
  set setId(int? id) => this.id = id;
  set setRoutineId(int routineId) => this.routineId = routineId;
  set setExerciseId(int exerciseId) => this.exerciseId = exerciseId;
  set setSets(int? sets) => this.sets = sets;
  set setReps(int? reps) => this.reps = reps;
  set setRestSeconds(int? restSeconds) => this.restSeconds = restSeconds;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routine_id': routineId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
    };
  }

  // Create from Map
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'],
      routineId: map['routine_id'],
      exerciseId: map['exercise_id'],
      sets: map['sets'],
      reps: map['reps'],
      restSeconds: map['rest_seconds'],
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        sets INTEGER,
        reps INTEGER,
        rest_seconds INTEGER,
        FOREIGN KEY(routine_id) REFERENCES routines(id),
        FOREIGN KEY(exercise_id) REFERENCES exercises(id)
      );
    ''';
  }
}

// Workout class
class Workout {
  int? id;
  int? routineId;
  DateTime? startedAt;
  DateTime? endedAt;

  Workout({this.id, this.routineId, this.startedAt, this.endedAt});

  // Getters
  int? get getId => id;
  int? get getRoutineId => routineId;
  DateTime? get getStartedAt => startedAt;
  DateTime? get getEndedAt => endedAt;

  // Setters
  set setId(int? id) => this.id = id;
  set setRoutineId(int? routineId) => this.routineId = routineId;
  set setStartedAt(DateTime? startedAt) => this.startedAt = startedAt;
  set setEndedAt(DateTime? endedAt) => this.endedAt = endedAt;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routine_id': routineId,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      routineId: map['routine_id'],
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'])
          : null,
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER,
        started_at TIMESTAMP,
        ended_at TIMESTAMP,
        FOREIGN KEY(routine_id) REFERENCES routines(id)
      );
    ''';
  }
}

// WorkoutLog class
class WorkoutLog {
  int? id;
  int workoutId;
  int exerciseId;
  int? setNumber;
  int? reps;
  double? weightKg;
  int? restSeconds;

  WorkoutLog({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    this.setNumber,
    this.reps,
    this.weightKg,
    this.restSeconds,
  });

  // Getters
  int? get getId => id;
  int get getWorkoutId => workoutId;
  int get getExerciseId => exerciseId;
  int? get getSetNumber => setNumber;
  int? get getReps => reps;
  double? get getWeightKg => weightKg;
  int? get getRestSeconds => restSeconds;

  // Setters
  set setId(int? id) => this.id = id;
  set setWorkoutId(int workoutId) => this.workoutId = workoutId;
  set setExerciseId(int exerciseId) => this.exerciseId = exerciseId;
  set setSetNumber(int? setNumber) => this.setNumber = setNumber;
  set setReps(int? reps) => this.reps = reps;
  set setWeightKg(double? weightKg) => this.weightKg = weightKg;
  set setRestSeconds(int? restSeconds) => this.restSeconds = restSeconds;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight_kg': weightKg,
      'rest_seconds': restSeconds,
    };
  }

  // Create from Map
  factory WorkoutLog.fromMap(Map<String, dynamic> map) {
    return WorkoutLog(
      id: map['id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
      setNumber: map['set_number'],
      reps: map['reps'],
      weightKg: map['weight_kg']?.toDouble(),
      restSeconds: map['rest_seconds'],
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE workout_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER,
        reps INTEGER,
        weight_kg DECIMAL,
        rest_seconds INTEGER,
        FOREIGN KEY(workout_id) REFERENCES workouts(id),
        FOREIGN KEY(exercise_id) REFERENCES exercises(id)
      );
    ''';
  }
}

// Helper class to get all table creation queries
class DatabaseSchema {
  static List<String> getAllCreateTableQueries() {
    return [
      MuscleGroup.createTableQuery(),
      Exercise.createTableQuery(),
      Routine.createTableQuery(),
      RoutineExercise.createTableQuery(),
      Workout.createTableQuery(),
      WorkoutLog.createTableQuery(),
    ];
  }
}
