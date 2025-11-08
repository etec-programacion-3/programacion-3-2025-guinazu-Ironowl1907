import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';
import 'package:workout_logger/services/workout_repository.dart';
import 'package:workout_logger/services/workout_set_repository.dart';

enum TypeFilter { heaviestWeight, bestSetVolume, totalVolume, totalReps }

enum TimeFilter { week, month, months3, year, all }

class ExerciseDetailsProvider extends ChangeNotifier {
  late WorkoutExerciseRepository exerciseRepo;
  late WorkoutRepository workoutRepo;
  late WorkoutSetRepository workoutSetRepo;
  late DatabaseService dbService;

  TypeFilter _typeFilter = TypeFilter.heaviestWeight;
  TimeFilter _timeFilter = TimeFilter.week;
  int selectedIndex = 0;
  int? selectedExerciseId;

  TypeFilter get typeFilter => _typeFilter;
  TimeFilter get timeFilter => _timeFilter;

  set timeFilter(TimeFilter other) {
    _timeFilter = other;
    load();
  }

  set typeFilter(TypeFilter other) {
    _typeFilter = other;
    load();
  }

  Map<DateTime, double>? _dataPoints;

  Map<DateTime, double>? get dataPoints => _dataPoints;

  ExerciseDetailsProvider({required this.dbService}) {
    exerciseRepo = WorkoutExerciseRepository(dbService);
    workoutRepo = WorkoutRepository(dbService);
    workoutSetRepo = WorkoutSetRepository(dbService);
    _typeFilter = TypeFilter.heaviestWeight;
    _timeFilter = TimeFilter.week;
  }

  Future<void> load() async {
    // This numbers used to include the workouts that were logged at the day of loading
    final DateTime now = DateTime.now().copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
      microsecond: 999,
    );

    late DateTime start;

    switch (_timeFilter) {
      case TimeFilter.week:
        start = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        start = now.subtract(const Duration(days: 30));
        break;
      case TimeFilter.months3:
        start = now.subtract(const Duration(days: 90));
        break;
      case TimeFilter.year:
        start = now.subtract(const Duration(days: 365));
        break;
      case TimeFilter.all:
        // Hack implementation
        start = DateTime(2000, 1, 1);
        break;
    }

    start = start.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    List<DetailedWorkoutExercise> list = await exerciseRepo.getByDate(
      start,
      now,
    );
    assert(selectedExerciseId != null);
    list = list
        .where(
          (DetailedWorkoutExercise exercise) =>
              exercise.exercise.id == selectedExerciseId,
        )
        .toList();

    _dataPoints = <DateTime, double>{};
    for (DetailedWorkoutExercise workoutExercise in list) {
      final Workout? workout = await workoutRepo.get(
        workoutExercise.workoutExercise.workoutId,
      );
      final DateTime workoutDate = workout!.endedAt!;
      final List<WorkoutSet> exerciseSets = await workoutSetRepo.getByExercise(
        workoutExercise.workoutExercise.id!,
      );

      switch (_typeFilter) {
        case TypeFilter.totalReps:
          _dataPoints![workoutDate] = exerciseSets
              .where((WorkoutSet set) => set.completed == 1)
              .fold<double>(
                0,
                (double prev, WorkoutSet value) => prev + value.reps!,
              );
          break;
        case TypeFilter.heaviestWeight:
          _dataPoints![workoutDate] = exerciseSets
              .where((WorkoutSet set) => set.completed == 1)
              .fold<double>(
                0,
                (double prev, WorkoutSet value) => max(prev, value.weightKg!),
              );
          break;
        case TypeFilter.bestSetVolume:
          _dataPoints![workoutDate] = exerciseSets
              .where((WorkoutSet set) => set.completed == 1)
              .fold<double>(
                0,
                (double prev, WorkoutSet value) =>
                    max(prev, value.weightKg! * value.reps!),
              );
          break;
        case TypeFilter.totalVolume:
          _dataPoints![workoutDate] = exerciseSets
              .where((WorkoutSet set) => set.completed == 1)
              .fold<double>(
                0,
                (double prev, WorkoutSet value) =>
                    prev + value.weightKg! * value.reps!,
              );
          break;
      }
    }

    selectedIndex = dataPoints!.length - 1;
    notifyListeners();
  }

  void setExercise(int exerciseId) {
    selectedExerciseId = exerciseId;
    if (dataPoints != null) dataPoints!.clear();
  }
}
