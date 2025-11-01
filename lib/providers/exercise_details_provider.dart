import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/workout_exercise_repository.dart';

enum TypeFilter { heaviestWeight, bestSetVolume, totalVolume, totalReps }

enum TimeFilter { week, month, months3, year, all }

class ExerciseDetailsProvider extends ChangeNotifier {
  late WorkoutExerciseRepository exerciseRepo;
  late DatabaseService dbService;

  late TypeFilter _typeFilter;
  late TimeFilter _timeFilter;

  Map<DateTime, double>? _dataPoints;

  Map<DateTime, double>? get dataPoints => _dataPoints;

  ExerciseDetailsProvider({required this.dbService}) {
    exerciseRepo = WorkoutExerciseRepository(dbService);
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

    // Reset start time to beginning of day
    start = start.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );

    final List<DetailedWorkoutExercise> list = await exerciseRepo.getByDate(
      start,
      now,
    );

    _dataPoints = <DateTime, double>{};
    // TODO: Process list based on _typeFilter to populate _dataPoints

    notifyListeners();
  }
}
