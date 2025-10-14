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
    return <String, dynamic>{'id': id, 'name': name};
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
    return <String, dynamic>{
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
    return <String, dynamic>{
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
  int order;
  int? sets;
  int? reps;
  int? restSeconds;

  RoutineExercise({
    this.id,
    required this.routineId,
    required this.exerciseId,
    required this.order,
    this.sets,
    this.reps,
    this.restSeconds,
  });

  // Getters
  int? get getId => id;
  int get getRoutineId => routineId;
  int get getExerciseId => exerciseId;
  int? get getOrder => order;
  int? get getSets => sets;
  int? get getReps => reps;
  int? get getRestSeconds => restSeconds;

  // Setters
  set setId(int? id) => this.id = id;
  set setRoutineId(int routineId) => this.routineId = routineId;
  set setExerciseId(int exerciseId) => this.exerciseId = exerciseId;
  set setSets(int? sets) => this.sets = sets;
  set setOrder(int order) => this.order = order;
  set setReps(int? reps) => this.reps = reps;
  set setRestSeconds(int? restSeconds) => this.restSeconds = restSeconds;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'routine_id': routineId,
      'exercise_id': exerciseId,
      'order': order,
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
      order: map['order'],
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
        `order` INTEGER,
        sets INTEGER,
        reps INTEGER,
        rest_seconds INTEGER,
        FOREIGN KEY(routine_id) REFERENCES routines(id),
        FOREIGN KEY(exercise_id) REFERENCES exercises(id)
      );
    ''';
  }
}

class Workout {
  int? id;
  String? title;
  int? routineId;
  DateTime? startedAt;
  DateTime? endedAt;

  Workout({this.id, this.title, this.routineId, this.startedAt, this.endedAt});

  // Getters
  int? get getId => id;
  String? get getTitle => title;
  int? get getRoutineId => routineId;
  DateTime? get getStartedAt => startedAt;
  DateTime? get getEndedAt => endedAt;

  // Setters
  set setId(int? id) => this.id = id;
  set setTitle(String? title) => this.title = title;
  set setRoutineId(int? routineId) => this.routineId = routineId;
  set setStartedAt(DateTime? startedAt) => this.startedAt = startedAt;
  set setEndedAt(DateTime? endedAt) => this.endedAt = endedAt;

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'routine_id': routineId,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      title: map['title'],
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
        title TEXT,
        routine_id INTEGER,
        started_at TIMESTAMP,
        ended_at TIMESTAMP,
        FOREIGN KEY(routine_id) REFERENCES routines(id)
      );
    ''';
  }
}

class WorkoutExercise {
  int? id;
  int workoutId;
  int exerciseId;
  int orderIndex;
  int sets;
  int reps;
  DateTime? completedAt;

  WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    required this.sets,
    required this.reps,
    this.completedAt,
  });

  int? get getId => id;
  int get getWorkoutId => workoutId;
  int get getExerciseId => exerciseId;
  int get getOrderIndex => orderIndex;
  DateTime? get getCompletedAt => completedAt;

  set setId(int? id) => this.id = id;
  set setWorkoutId(int workoutId) => this.workoutId = workoutId;
  set setExerciseId(int exerciseId) => this.exerciseId = exerciseId;
  set setOrderIndex(int orderIndex) => this.orderIndex = orderIndex;
  set setSets(int sets) => this.sets = sets;
  set setReps(int reps) => this.reps = reps;
  set setCompletedAt(DateTime? completedAt) => this.completedAt = completedAt;

  bool get isCompleted => completedAt != null;
  void markCompleted() => completedAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'reps': reps,
      'sets': sets,
      'order_index': orderIndex,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
      orderIndex: map['order_index'],
      sets: map['sets'],
      reps: map['reps'],
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }

  static String createTableQuery() {
    return '''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        completed_at TIMESTAMP,
        FOREIGN KEY(workout_id) REFERENCES workouts(id),
        FOREIGN KEY(exercise_id) REFERENCES exercises(id)
      );
    ''';
  }
}

class WorkoutSet {
  int? id;
  int workoutExerciseId;
  int setNumber;
  int? reps;
  double? weightKg;
  int? durationSeconds;
  int? restSeconds;
  String? notes;
  DateTime? completedAt;

  WorkoutSet({
    this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.restSeconds,
    this.notes,
    this.completedAt,
  });

  // Getters
  int? get getId => id;
  int get getWorkoutExerciseId => workoutExerciseId;
  int get getSetNumber => setNumber;
  int? get getReps => reps;
  double? get getWeightKg => weightKg;
  int? get getDurationSeconds => durationSeconds;
  int? get getRestSeconds => restSeconds;
  String? get getNotes => notes;
  DateTime? get getCompletedAt => completedAt;

  // Setters
  set setId(int? id) => this.id = id;
  set setWorkoutExerciseId(int workoutExerciseId) =>
      this.workoutExerciseId = workoutExerciseId;
  set setSetNumber(int setNumber) => this.setNumber = setNumber;
  set setReps(int? reps) => this.reps = reps;
  set setWeightKg(double? weightKg) => this.weightKg = weightKg;
  set setDurationSeconds(int? durationSeconds) =>
      this.durationSeconds = durationSeconds;
  set setRestSeconds(int? restSeconds) => this.restSeconds = restSeconds;
  set setNotes(String? notes) => this.notes = notes;
  set setCompletedAt(DateTime? completedAt) => this.completedAt = completedAt;

  // Helper methods
  bool get isCompleted => completedAt != null;
  void markCompleted() => completedAt = DateTime.now();

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'workout_exercise_id': workoutExerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight_kg': weightKg,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Create from Map
  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      workoutExerciseId: map['workout_exercise_id'],
      setNumber: map['set_number'],
      reps: map['reps'],
      weightKg: map['weight_kg']?.toDouble(),
      durationSeconds: map['duration_seconds'],
      restSeconds: map['rest_seconds'],
      notes: map['notes'],
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }

  // SQL creation query
  static String createTableQuery() {
    return '''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER,
        weight_kg REAL,
        duration_seconds INTEGER,
        rest_seconds INTEGER,
        notes TEXT,
        completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(workout_exercise_id) REFERENCES workout_exercises(id)
      );
    ''';
  }
}

class DetailedRoutineExercise {
  Exercise exercise;
  RoutineExercise routineExercise;

  DetailedRoutineExercise(this.exercise, this.routineExercise);
}

class DetailedWorkoutExercise {
  Exercise exercise;
  WorkoutExercise workoutExercise;

  DetailedWorkoutExercise(this.exercise, this.workoutExercise);
}

// Helper class to get all table creation queries
class DatabaseSchema {
  static List<String> getAllCreateTableQueries() {
    return <String>[
      MuscleGroup.createTableQuery(),
      Exercise.createTableQuery(),
      Routine.createTableQuery(),
      RoutineExercise.createTableQuery(),
      Workout.createTableQuery(),
      WorkoutExercise.createTableQuery(),
      WorkoutSet.createTableQuery(),
    ];
  }
}
