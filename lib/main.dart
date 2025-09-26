import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workout_logger/providers/app_state_provider.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';
import 'package:workout_logger/providers/routine_exercise_provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/providers/workout_exercise_provider.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/providers/workout_set_provider.dart';
import 'package:workout_logger/services/database_service.dart';
import 'widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  DatabaseService dbService = DatabaseService();
  dbService.initDB();

  runApp(MyApp(dbService: dbService));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dbService});

  final DatabaseService dbService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MuscleGroupProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => ExerciseProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => RoutineProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => RoutineExerciseProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkoutExerciseProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkoutSetProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkoutProvider(dbService: dbService),
        ),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
        ),
        home: AppNavigation(),
      ),
    );
  }
}
