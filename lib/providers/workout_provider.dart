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
  final List<DetailedWorkoutExercise> _currentWorkoutExercises =
      <DetailedWorkoutExercise>[];

  Routine? get currentRoutine => _currentRoutine;
  Workout? get currentWorkout => _currentWorkout;
  List<DetailedWorkoutExercise>? get workoutExercises =>
      _currentWorkoutExercises;

  WorkoutProvider({required this.dbService}) {
    workoutRepo = WorkoutRepository(dbService);
    routineRepo = RoutineRepository(dbService);
    workoutExerciseRepo = WorkoutExerciseRepository(dbService);
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

      await workoutExerciseRepo.create(workoutExercise);
      _currentWorkoutExercises.add(
        DetailedWorkoutExercise(detailedExercise.exercise, workoutExercise),
      );
    }
    _currentWorkout = workout;
    return workout;
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
