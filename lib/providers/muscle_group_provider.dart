import 'package:flutter/foundation.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/muscle_group_repository.dart';

class MuscleGroupProvider extends ChangeNotifier {
  late MuscleGroupRepository muscleGroupsRepo;
  late DatabaseService dbService;

  List<MuscleGroup> _muscleGroup = <MuscleGroup>[];

  List<MuscleGroup> get muscleGroups => _muscleGroup;

  MuscleGroupProvider({required this.dbService}) {
    muscleGroupsRepo = MuscleGroupRepository(dbService);
  }

  Future<void> load() async {
    _muscleGroup = await muscleGroupsRepo.getAll();
    notifyListeners();
  }

  Future<MuscleGroup?> get(int id) async {
    return muscleGroupsRepo.get(id);
  }

  Future<void> add(MuscleGroup muscleGroup) async {
    if (await muscleGroupsRepo.create(muscleGroup) == 0) {
      print('Error insering muscle group');
    }
    load();
  }

  Future<void> delete(MuscleGroup muscleGroup) async {
    if (await muscleGroupsRepo.delete(muscleGroup.id!) == 0) {
      print('Error deleting muscle group');
    }
    load();
  }

  Future<void> update(MuscleGroup muscleGroup) async {
    if (await muscleGroupsRepo.update(muscleGroup) == 0) {
      print('Error updating muscle group');
    }
    load();
  }
}
