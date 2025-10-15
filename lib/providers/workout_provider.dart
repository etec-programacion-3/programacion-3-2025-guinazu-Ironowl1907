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

  Routine? _currentRoutine;
  Workout? _currentWorkout;
  final List<WorkoutExercise> _currentWorkoutExercises = <WorkoutExercise>[];

  Routine? get currentRoutine => _currentRoutine;
  Workout? get currentWorkout => _currentWorkout;
  List<WorkoutExercise>? get workoutExercises => _currentWorkoutExercises;

  WorkoutProvider({required this.dbService}) {
    workoutRepo = WorkoutRepository(dbService);
    routineRepo = RoutineRepository(dbService);
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
    workoutSetRepo = WorkoutSetRepository(dbService);
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

    // Creating the workout object
    final Workout newWorkout = Workout(
      title: currentRoutine == null ? 'Unamed' : currentRoutine!.name,
      routineId: currentRoutine!.id,
      startedAt: DateTime.now(),
    );

    // Loading it on the db
    final int workoutId = await workoutRepo.createWorkout(newWorkout);
    newWorkout.id = workoutId;

    // Geting the exercises from the routine
    final List<DetailedRoutineExercise> routineExericises = await routineRepo
        .getDetailedRoutineExercisesByRoutine(currentRoutine!.id!);

    final List<WorkoutExercise> workoutExercises = <WorkoutExercise>[];
    for (int i = 0; i < routineExericises.length; i++) {
      // Create the workout exercises
      final DetailedRoutineExercise exercise = routineExericises[i];
      final WorkoutExercise we = WorkoutExercise(
        workoutId: currentWorkout!.id!,
        exerciseId: exercise.exercise.id!,
        orderIndex: i + 1,
        sets: exercise.routineExercise.sets!,
        reps: exercise.routineExercise.reps!,
      );
      we.id = await workoutExerciseRepo.create(we);
      workoutExercises.add(we);

      // Create the workout sets as default uncompleted
      for (int ie = 0; ie < exercise.routineExercise.sets!; ie++) {
        final WorkoutSet workoutSet = WorkoutSet(
          workoutExerciseId: we.id!,
          setNumber: ie + 1,
          reps: exercise.routineExercise.reps!,
          weightKg: 100, //TODO: Remove placeholder
        );
        workoutSetRepo.create(workoutSet);
      }
    }

    return newWorkout;
  }

  Future<void> finishWorkout(Workout workout) async {}

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
}
