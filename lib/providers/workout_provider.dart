import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';
import 'package:workout_logger/services/workout_repository.dart';
import 'package:workout_logger/services/workout_set_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  late WorkoutRepository workoutRepo;
  late RoutineRepository routineRepo;
  late WorkoutExerciseRepository workoutExerciseRepo;
  late WorkoutSetRepository workoutSetRepo;
  late DatabaseService dbService;

  List<Workout>? _workouts;
  List<Workout>? get workouts => _workouts;

  Routine? _currentRoutine;
  Workout? _currentWorkout;
  final Map<int, DetailedWorkoutExercise> _currentWorkoutExercises =
      <int, DetailedWorkoutExercise>{};
  final Map<int, List<WorkoutSet>> _workoutSets = <int, List<WorkoutSet>>{};

  Routine? get currentRoutine => _currentRoutine;
  Workout? get currentWorkout => _currentWorkout;
  Map<int, DetailedWorkoutExercise> get workoutExercises =>
      _currentWorkoutExercises;
  Map<int, List<WorkoutSet>> get workoutSets => _workoutSets;

  WorkoutProvider({required this.dbService}) {
    workoutRepo = WorkoutRepository(dbService);
    routineRepo = RoutineRepository(dbService);
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
    workoutSetRepo = WorkoutSetRepository(dbService);
  }

  Future<void> load() async {
    _workouts = await workoutRepo.getAll();
    notifyListeners();
  }

  Future<int> update(Workout workout) async {
    return workoutRepo.update(workout);
  }

  Future<Workout?> initializeWorkout(Routine? routine) async {
    if (routine == null) {
      print('TODO freeform workout');
      return null;
    }
    print('initialize workout');
    _currentRoutine = routine;

    final Workout newWorkout = Workout(
      title: currentRoutine == null ? 'Unamed' : currentRoutine!.name,
      routineId: currentRoutine!.id,
      startedAt: DateTime.now(),
    );

    final int workoutId = await workoutRepo.createWorkout(newWorkout);
    newWorkout.id = workoutId;
    _currentWorkout = newWorkout;

    final List<DetailedRoutineExercise> routineExericises = await routineRepo
        .getDetailedRoutineExercisesByRoutine(currentRoutine!.id!);

    _currentWorkoutExercises.clear();
    _workoutSets.clear();

    for (int i = 0; i < routineExericises.length; i++) {
      final DetailedRoutineExercise exercise = routineExericises[i];
      final WorkoutExercise we = WorkoutExercise(
        workoutId: currentWorkout!.id!,
        exerciseId: exercise.exercise.id!,
        orderIndex: i + 1,
        sets: exercise.routineExercise.sets!,
        reps: exercise.routineExercise.reps!,
      );
      final DetailedWorkoutExercise dwe = DetailedWorkoutExercise(
        exercise.exercise,
        we,
      );
      we.id = await workoutExerciseRepo.create(we);

      _currentWorkoutExercises[we.id!] = dwe;

      final List<WorkoutSet> sets = <WorkoutSet>[];
      for (int ie = 0; ie < exercise.routineExercise.sets!; ie++) {
        final WorkoutSet workoutSet = WorkoutSet(
          workoutExerciseId: we.id!,
          setNumber: ie + 1,
          reps: exercise.routineExercise.reps!,
          weightKg: 100, //TODO: Remove placeholder
        );
        workoutSet.id = await workoutSetRepo.create(workoutSet);
        sets.add(workoutSet);
      }

      _workoutSets[we.id!] = sets;
    }

    // Debug printing
    print('\n=== Workout Initialized ===');
    print('Workout ID: ${newWorkout.id}');
    print('Total Exercises: ${_currentWorkoutExercises.length}');
    print('\nWorkout Exercises and Sets:');

    _currentWorkoutExercises.forEach((
      int exerciseId,
      DetailedWorkoutExercise workoutExercise,
    ) {
      print('\n--- Exercise ID: $exerciseId ---');
      print('  Exercise DB ID: ${workoutExercise.workoutExercise.exerciseId}');
      print('  Order: ${workoutExercise.workoutExercise.orderIndex}');
      print('  Target Sets: ${workoutExercise.workoutExercise.sets}');
      print('  Target Reps: ${workoutExercise.workoutExercise.reps}');

      final List<WorkoutSet>? sets = _workoutSets[exerciseId];
      if (sets != null) {
        print('  Sets (${sets.length}):');
        for (final WorkoutSet set in sets) {
          print(
            '    Set ${set.setNumber}: ${set.reps} reps @ ${set.weightKg}kg (ID: ${set.id})',
          );
        }
      } else {
        print('  No sets found');
      }
    });

    print('\n=========================\n');

    notifyListeners();
    return newWorkout;
  }

  Future<void> finishWorkout(Workout workout) async {
    if (_currentWorkout == null) {
      print('Error workout null');
    }
    _currentWorkout!.setEndedAt = DateTime.now();
    workoutRepo.update(_currentWorkout!);
    _currentRoutine = null;
    _currentWorkout = null;
    _currentWorkoutExercises.clear();
  }

  Future<Workout?> getUnfinishedWorkout() async {
    final Database db = dbService.db!;
    final List<Map<String, Object?>> result = await db.query(
      'workouts',
      where: 'ended_at IS NULL',
      orderBy: 'started_at DESC', // Get most recent
      limit: 1,
    );

    if (result.isEmpty) return null;

    final Workout workout = Workout.fromMap(result[0]);
    return workout;
  }

  Future<int> delete(int workoutId) async {
    final Database db = dbService.db!;
    final Future<int> id = db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: <Object?>[workoutId],
    );

    load();
    return id;
  }
}
