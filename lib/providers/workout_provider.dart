import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  late WorkoutRepository workoutRepo;
  late DatabaseService dbService;

  final List<Workout> _workouts = <Workout>[];

  List<Workout> get workouts => _workouts;

  WorkoutProvider({required this.dbService}) {
    workoutRepo = WorkoutRepository(dbService);
  }

  Future<Workout?> initializeWorkout(Routine? routine) async {
    if (routine == null) {
      print('TODO freeform workout');
      return null;
    }
    print("initialize workout");

    final Workout workout = Workout(
      title: 'Unnamed Workout',
      routineId: routine.id,
    );
    final int id = await workoutRepo.createWorkout(workout);
    workout.id = id;
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
