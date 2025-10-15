import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';
import 'package:workout_logger/services/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  late WorkoutRepository workoutRepo;
  late RoutineRepository routineRepo;
  late WorkoutExerciseRepository workoutExerciseRepo;
  late DatabaseService dbService;

  Routine? _currentRoutine;
  Workout? _currentWorkout;
  List<DetailedWorkoutExerciseWithSets>? _currentWorkoutExercises =
      <DetailedWorkoutExerciseWithSets>[];

  Routine? get currentRoutine => _currentRoutine;
  Workout? get currentWorkout => _currentWorkout;
  List<DetailedWorkoutExerciseWithSets>? get workoutExercises =>
      _currentWorkoutExercises;

  WorkoutProvider({required this.dbService}) {
    workoutRepo = WorkoutRepository(dbService);
    routineRepo = RoutineRepository(dbService);
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
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

    final Workout workout = Workout(
      title: 'Unnamed Workout',
      routineId: routine.id,
      startedAt: DateTime.now(),
    );
    final int id = await workoutRepo.createWorkout(workout);
    workout.id = id;

    _currentRoutine = routine;
    _currentWorkoutExercises = <DetailedWorkoutExerciseWithSets>[];

    final List<DetailedRoutineExercise> currentRoutineExercise =
        await routineRepo.getDetailedRoutineExercisesByRoutine(routine.id!);

    for (final DetailedRoutineExercise detailedExercise
        in currentRoutineExercise) {
      final WorkoutExercise workoutExercise = WorkoutExercise(
        workoutId: id,
        exerciseId: detailedExercise.exercise.id!,
        orderIndex: detailedExercise.routineExercise.order,
        sets: detailedExercise.routineExercise.sets ?? 3,
        reps: detailedExercise.routineExercise.reps ?? 10,
      );

      workoutExercise.id = await workoutExerciseRepo.create(workoutExercise);
      _currentWorkoutExercises!.add(
        DetailedWorkoutExerciseWithSets(
          detailedExercise.exercise,
          workoutExercise,
          List.generate(detailedExercise.routineExercise.getSets!, (int index) {
            return WorkoutSet(
              workoutExerciseId: workoutExercise.id!,
              setNumber: index + 1,
            );
          }),
        ),
      );
    }
    _currentWorkout = workout;
    print('=== Workout Initialized ===');
    print('Workout ID: ${workout.id}');
    print('Workout Title: ${workout.title}');
    print('Routine: ${routine.name} (ID: ${routine.id})');
    print('Started At: ${workout.startedAt}');
    print('Total Exercises: ${_currentWorkoutExercises!.length}');
    print('');

    for (int i = 0; i < _currentWorkoutExercises!.length; i++) {
      final DetailedWorkoutExerciseWithSets detailedExercise =
          _currentWorkoutExercises![i];
      print('Exercise ${i + 1}: ${detailedExercise.exercise.name}');
      print('  - Exercise ID: ${detailedExercise.exercise.id}');
      print('  - WorkoutExercise ID: ${detailedExercise.workoutExercise.id}');
      print('  - Order: ${detailedExercise.workoutExercise.orderIndex}');
      print('  - Total Sets: ${detailedExercise.workoutExercise.sets}');
      print('  - Default Reps: ${detailedExercise.workoutExercise.reps}');
      print('  - Sets:');
      for (WorkoutSet set in detailedExercise.sets) {
        print('   ${set.toMap()}');
      }

      print('');
    }
    print('=========================');

    return workout;
  }

  Future<void> finishWorkout(Workout workout) async {
    print('Finishing workout');
    _currentWorkout!.setEndedAt = DateTime.now();
    update(workout);

    _currentRoutine = null;
    _currentWorkout = null;
    _currentWorkoutExercises = null;
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
}
