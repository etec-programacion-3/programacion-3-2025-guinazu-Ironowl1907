import 'package:flutter/widgets.dart';
import 'package:workout_logger/models/models.dart';

class AppStateProvider extends ChangeNotifier {
  int _currentIndex = 0;
  Workout? _currentWorkout;
  bool _isLoadingWorkout = true;

  int get navBarIndex => _currentIndex;
  Workout? get currentWorkout => _currentWorkout;
  bool get isLoadingWorkout => _isLoadingWorkout;

  void setCurrentWorkout(Workout? other) {
    _currentWorkout = other;
    notifyListeners();
  }

  void setCurrentIndex(int other) {
    _currentIndex = other;
    notifyListeners();
  }

  void setIsLoadingWorkout(bool other) {
    _isLoadingWorkout = other;
    notifyListeners();
  }

  // Future<Workout?> getCurrentWorkout() {
  //   // TODO
  // }
}
