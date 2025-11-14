import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/services/muscle_group_repository.dart';

@GenerateMocks(<Type>[DatabaseService, Database])
import 'muscle_group_repository_test.mocks.dart';

void main() {
  late MuscleGroupRepository repository;
  late MockDatabaseService mockDbService;
  late MockDatabase mockDb;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDb = MockDatabase();
    when(mockDbService.db).thenReturn(mockDb);
    repository = MuscleGroupRepository(mockDbService);
  });

  group('MuscleGroupRepository', () {
    final MuscleGroup testMuscleGroup = MuscleGroup(id: 1, name: 'Chest');

    test('create should insert muscle group and return id', () async {
      when(
        mockDb.insert('muscle_groups', testMuscleGroup.toMap()),
      ).thenAnswer((_) async => 1);

      final int result = await repository.create(testMuscleGroup);

      expect(result, 1);
      verify(mockDb.insert('muscle_groups', testMuscleGroup.toMap())).called(1);
    });

    test('get should return muscle group when found', () async {
      when(
        mockDb.query('muscle_groups', where: 'id = ?', whereArgs: <int>[1]),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[testMuscleGroup.toMap()],
      );

      final MuscleGroup? result = await repository.get(1);

      expect(result, isNotNull);
      expect(result?.id, 1);
      expect(result?.name, 'Chest');
    });

    test('get should return null when not found', () async {
      when(
        mockDb.query('muscle_groups', where: 'id = ?', whereArgs: <int>[999]),
      ).thenAnswer((_) async => <Map<String, Object?>>[]);

      final MuscleGroup? result = await repository.get(999);

      expect(result, isNull);
    });

    test('getAll should return list of muscle groups', () async {
      final List<Map<String, dynamic>> testList = <Map<String, dynamic>>[
        testMuscleGroup.toMap(),
        MuscleGroup(id: 2, name: 'Back').toMap(),
      ];

      when(mockDb.query('muscle_groups')).thenAnswer((_) async => testList);

      final List<MuscleGroup> result = await repository.getAll();

      expect(result.length, 2);
      expect(result[0].name, 'Chest');
      expect(result[1].name, 'Back');
    });

    test(
      'update should update muscle group and return affected rows',
      () async {
        when(
          mockDb.update(
            'muscle_groups',
            testMuscleGroup.toMap(),
            where: 'id = ?',
            whereArgs: <int>[1],
          ),
        ).thenAnswer((_) async => 1);

        final int result = await repository.update(testMuscleGroup);

        expect(result, 1);
        verify(
          mockDb.update(
            'muscle_groups',
            testMuscleGroup.toMap(),
            where: 'id = ?',
            whereArgs: <int>[1],
          ),
        ).called(1);
      },
    );

    test(
      'delete should remove muscle group and return affected rows',
      () async {
        when(
          mockDb.delete('muscle_groups', where: 'id = ?', whereArgs: <int>[1]),
        ).thenAnswer((_) async => 1);

        final int result = await repository.delete(1);

        expect(result, 1);
        verify(
          mockDb.delete('muscle_groups', where: 'id = ?', whereArgs: <int>[1]),
        ).called(1);
      },
    );
  });
}
