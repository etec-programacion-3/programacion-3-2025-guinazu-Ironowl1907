import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/routine_exercise_repository.dart';
import 'package:workout_logger/services/routine_repository.dart';

class RoutineProvider extends ChangeNotifier {
  late RoutineRepository routineRepo;
  late RoutineExerciseRepository exerciseRepo;
  late DatabaseService dbService;
  List<Routine> _routines = <Routine>[];
  List<Routine> get routines => _routines;

  int? newRoutineId;
  List<RoutineExercise> _creationExercises = <RoutineExercise>[];
  List<RoutineExercise> get creationExercises => _creationExercises;

  List<int> _originalExerciseIds = <int>[];

  String _routineName = '';
  String get routineName => _routineName;

  String _routineDescription = '';
  String get routineDescription => _routineDescription;

  RoutineProvider({required this.dbService}) {
    routineRepo = RoutineRepository(dbService);
    exerciseRepo = RoutineExerciseRepository(dbService);
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

  Future<void> initializeCreation(Routine? routine) async {
    if (routine == null) {
      newRoutineId = null;
      _routineName = 'Unnamed';
      _routineDescription = '';
      _creationExercises = <RoutineExercise>[];
      _originalExerciseIds = <int>[];
    } else {
      newRoutineId = routine.id;
      _routineName = routine.name;
      _routineDescription = routine.description ?? '';
      final List<DetailedRoutineExercise> detailedRoutineExercise =
          await routineRepo.getDetailedRoutineExercisesByRoutine(routine.id!);

      _creationExercises = detailedRoutineExercise
          .map((DetailedRoutineExercise i) => i.routineExercise)
          .toList();

      _originalExerciseIds = _creationExercises
          .where((RoutineExercise e) => e.id != null)
          .map((RoutineExercise e) => e.id!)
          .toList();
    }
    notifyListeners();
  }

  void setRoutineName(String name) {
    _routineName = name;
    load();
  }

  void setRoutineDescription(String description) {
    _routineDescription = description;
    load();
  }

  void addExerciseToCreation(
    int exerciseId, {
    int? sets,
    int? reps,
    int? restSeconds,
  }) {
    final RoutineExercise newExercise = RoutineExercise(
      routineId: newRoutineId ?? 0,
      exerciseId: exerciseId,
      order: _creationExercises.length,
      sets: sets ?? 3,
      reps: reps ?? 10,
      restSeconds: restSeconds ?? 60,
    );
    _creationExercises.add(newExercise);
    load();
  }

  void removeExerciseFromCreation(int index) {
    _creationExercises.removeAt(index);
    for (int i = 0; i < _creationExercises.length; i++) {
      _creationExercises[i].order = i;
    }
    load();
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
    load();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final RoutineExercise exercise = _creationExercises.removeAt(oldIndex);
    _creationExercises.insert(newIndex, exercise);
    for (int i = 0; i < _creationExercises.length; i++) {
      _creationExercises[i].order = i;
    }
    load();
  }

  void clearCreation() {
    _routineName = '';
    _routineDescription = '';
    _creationExercises = <RoutineExercise>[];
    _originalExerciseIds = <int>[];
    load();
  }

  bool get isCreationValid {
    return _routineName.isNotEmpty && _creationExercises.isNotEmpty;
  }

  Future<List<DetailedRoutineExercise>> getDetailedRoutineExercisesByRoutine(
    int routineId,
  ) async {
    return routineRepo.getDetailedRoutineExercisesByRoutine(routineId);
  }

  Future<int> saveCreation() async {
    if (newRoutineId == null) {
      newRoutineId = await routineRepo.create(
        Routine(name: routineName, description: routineDescription),
      );
    } else {
      await routineRepo.update(
        Routine(
          id: newRoutineId,
          name: routineName,
          description: routineDescription,
        ),
      );
    }

    final Set<int> currentExerciseIds = <int>{};

    for (RoutineExercise exercise in creationExercises) {
      exercise.routineId = newRoutineId!;

      if (exercise.id == null) {
        final int newId = await exerciseRepo.create(exercise);
        exercise.id = newId;
        currentExerciseIds.add(newId);
      } else {
        await exerciseRepo.update(exercise);
        currentExerciseIds.add(exercise.id!);
      }
    }

    for (int originalId in _originalExerciseIds) {
      if (!currentExerciseIds.contains(originalId)) {
        await exerciseRepo.delete(originalId);
      }
    }

    await load();
    return newRoutineId!;
  }
}
