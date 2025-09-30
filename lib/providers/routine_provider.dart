import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_repository.dart';

class RoutineProvider extends ChangeNotifier {
  late RoutineRepository routineRepo;
  late DatabaseService dbService;
  List<Routine> _routines = <Routine>[];
  List<Routine> get routines => _routines;

  // For creation/editing
  int? newRoutineId;
  List<RoutineExercise> _creationExercises = <RoutineExercise>[];
  List<RoutineExercise> get creationExercises => _creationExercises;

  String _routineName = '';
  String get routineName => _routineName;

  String _routineDescription = '';
  String get routineDescription => _routineDescription;

  RoutineProvider({required this.dbService}) {
    routineRepo = RoutineRepository(dbService);
  }

  Future<void> load() async {
    _routines = await routineRepo.getAll();
    notifyListeners();
  }

  Future<void> add(Routine routine) async {
    if (await routineRepo.create(routine) == 0) {
      print('Error inserting routine');
    }
    load();
  }

  Future<void> delete(Routine routine) async {
    if (await routineRepo.delete(routine.id!) == 0) {
      print('Error deleting routine');
    }
    load();
  }

  Future<void> update(Routine routine) async {
    if (await routineRepo.update(routine) == 0) {
      print('Error updating routine');
    }
    load();
  }

  // Creation methods
  Future<void> initializeCreation() async {
    newRoutineId = await routineRepo.create(Routine(name: 'Unamed'));
    _routineName = 'Unamed';
    _routineDescription = '';
    _creationExercises = <RoutineExercise>[];
    notifyListeners();
  }

  void setRoutineName(String name) {
    _routineName = name;
    notifyListeners();
  }

  void setRoutineDescription(String description) {
    _routineDescription = description;
    notifyListeners();
  }

  void addExerciseToCreation(
    int exerciseId, {
    int? sets,
    int? reps,
    int? restSeconds,
  }) {
    final RoutineExercise newExercise = RoutineExercise(
      routineId: 0, // Temporary, will be set when saving
      exerciseId: exerciseId,
      order: _creationExercises.length,
      sets: sets ?? 3,
      reps: reps ?? 10,
      restSeconds: restSeconds ?? 60,
    );
    _creationExercises.add(newExercise);
    notifyListeners();
  }

  void removeExerciseFromCreation(int index) {
    _creationExercises.removeAt(index);
    // Update order
    for (int i = 0; i < _creationExercises.length; i++) {
      _creationExercises[i].order = i;
    }
    notifyListeners();
  }

  void updateExerciseInCreation(
    int index, {
    int? sets,
    int? reps,
    int? restSeconds,
  }) {
    if (sets != null) _creationExercises[index].sets = sets;
    if (reps != null) _creationExercises[index].reps = reps;
    if (restSeconds != null) {
      _creationExercises[index].restSeconds = restSeconds;
    }
    notifyListeners();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final RoutineExercise exercise = _creationExercises.removeAt(oldIndex);
    _creationExercises.insert(newIndex, exercise);
    // Update order
    for (int i = 0; i < _creationExercises.length; i++) {
      _creationExercises[i].order = i;
    }
    notifyListeners();
  }

  void clearCreation() {
    _routineName = '';
    _routineDescription = '';
    _creationExercises = <RoutineExercise>[];
    notifyListeners();
  }

  bool get isCreationValid {
    return _routineName.isNotEmpty && _creationExercises.isNotEmpty;
  }

  Future<List<DetailedRoutineExercise>> getDetailedRoutineExercisesByRoutine(
    int routineId,
  ) async {
    return routineRepo.getDetailedRoutineExercisesByRoutine(routineId);
  }
}
