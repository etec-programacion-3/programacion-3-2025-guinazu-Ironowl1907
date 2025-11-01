import 'package:flutter/foundation.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/exercise_repository.dart';

enum TypeFilter { heaviestWeight, bestSetVolume, totalVolume, totalReps }

enum TimeFilter { week, month, year, all }

class ExerciseProvider extends ChangeNotifier {
  late ExerciseRepository exerciseRepo;
  late DatabaseService dbService;

  late TypeFilter _typeFilter;
  late TimeFilter _timeFilter;

  Map<DateTime, double>? _dataPoints;

  Map<DateTime, double>? get dataPoints => _dataPoints;

  ExerciseProvider({required this.dbService}) {
    exerciseRepo = ExerciseRepository(dbService);
    _typeFilter = TypeFilter.heaviestWeight;
    _timeFilter = TimeFilter.week;
  }

  Future<void> load() async {
    notifyListeners();
  }
}
