import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';
import 'package:workout_logger/services/routine_exercise_repository.dart';
import 'package:workout_logger/services/exercise_repository.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';
import 'package:workout_logger/services/workout_repository.dart';
import 'package:workout_logger/services/workout_set_repository.dart';

class AppNotifier extends ChangeNotifier {
  late ExerciseRepository exercisesRepo;
  late RoutineRepository routinesRepo;
  late RoutineExerciseRepository routinesExerciseRepo;
  late WorkoutExerciseRepository workoutExerciseRepo;
  late WorkoutSetRepository workoutSetRepo;
  late WorkoutRepository workoutRepo;

  late DatabaseService dbService;

  AppNotifier() {
    dbService = DatabaseService();
    dbService.initDB();

    exercisesRepo = ExerciseRepository(dbService);
    routinesRepo = RoutineRepository(dbService);
    routinesExerciseRepo = RoutineExerciseRepository(dbService);
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
    workoutSetRepo = WorkoutSetRepository(dbService);
    workoutRepo = WorkoutRepository(dbService);
  }

  List<Workout> _workouts = [];
  List<Exercise> _exercises = [];
  List<Routine> _routines = [];

  List<Workout> get workouts => _workouts;
  List<Exercise> get exercises => _exercises;
  List<Routine> get routines => _routines;

  // ===== WORKOUTS =====
  Future<void> loadWorkouts() async {
    _workouts = await workoutRepo.getAllWorkouts();
    notifyListeners();
  }

  Future<void> addWorkout(Workout workout) async {
    await workoutRepo.createWorkout(workout);
    await loadWorkouts();
  }

  Future<void> updateWorkout(Workout workout) async {
    await workoutRepo.updateWorkout(workout);
    await loadWorkouts();
  }

  Future<void> deleteWorkout(int id) async {
    await workoutRepo.deleteWorkout(id);
    await loadWorkouts();
  }

  // ===== EXERCISES =====
  Future<void> loadExercises() async {
    _exercises = await exercisesRepo.getAll();
    notifyListeners();
  }

  Future<void> addExercise(Exercise exercise) async {
    await exercisesRepo.create(exercise);
    await loadExercises();
  }

  // ===== ROUTINES =====
  Future<void> loadRoutines() async {
    _routines = await routinesRepo.getAll();
    notifyListeners();
  }

  Future<void> addRoutine(Routine routine) async {
    await routinesRepo.create(routine);
    await loadRoutines();
  }
}
