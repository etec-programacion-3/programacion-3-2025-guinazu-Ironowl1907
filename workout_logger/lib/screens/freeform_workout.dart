import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:workout_logger/utils/workout_utils.dart';

class FreeFormWorkoutPage extends StatefulWidget {
  final ActiveWorkoutData? activeWorkoutData;

  const FreeFormWorkoutPage({super.key, this.activeWorkoutData});

  @override
  State<FreeFormWorkoutPage> createState() => _FreeFormWorkoutPageState();
}

class _FreeFormWorkoutPageState extends State<FreeFormWorkoutPage> {
  Workout? _runningWorkout;
  List<WorkoutLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  void _initializeWorkout() {
    if (widget.activeWorkoutData != null) {
      // Use provided active workout data
      setState(() {
        _runningWorkout = widget.activeWorkoutData!.workout;
        _logs = widget.activeWorkoutData!.logs;
      });
    }
    // If no active workout data provided, we start fresh (no workout running)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log Workout")),
      body: _freeFormWorkout(),
    );
  }

  Future<void> _startWorkout() async {
    final db = DatabaseService.instance;
    final workoutId = await db.startWorkout(0); // routineId = 0 for free form
    final workout = await db.getWorkoutById(workoutId);

    setState(() {
      _runningWorkout = workout;
      _logs = [];
    });
  }

  Future<void> _endWorkout() async {
    if (_runningWorkout == null) return;

    await WorkoutUtils.endWorkout(_runningWorkout!.id!);

    setState(() {
      _runningWorkout = null;
      _logs = [];
    });
  }

  Future<void> _addSet(int exerciseId, int reps, double weight) async {
    if (_runningWorkout == null) return;

    final db = DatabaseService.instance;
    final log = WorkoutLog(
      workoutId: _runningWorkout!.id!,
      exerciseId: exerciseId,
      setNumber: _logs.length + 1,
      reps: reps,
      weightKg: weight,
    );

    final id = await db.insertWorkoutLog(log);
    log.id = id;

    setState(() {
      _logs.add(log);
    });
  }

  Widget _freeFormWorkout() {
    if (_runningWorkout != null) {
      return Column(
        children: [
          workoutStatus(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _addSet(1, 10, 50.0), // dummy exercise example
            child: const Text("Add Set"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _endWorkout,
            child: const Text("End Workout"),
          ),
        ],
      );
    }

    return Column(
      children: [
        workoutStatus(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startWorkout,
          child: const Text("Start Workout"),
        ),
      ],
    );
  }

  Column workoutStatus() {
    final duration = _runningWorkout?.startedAt != null
        ? DateTime.now().difference(_runningWorkout!.startedAt!)
        : Duration.zero;

    final volume = _logs.fold<double>(
      0,
      (sum, l) => sum + (l.weightKg ?? 0) * (l.reps ?? 0),
    );
    final sets = _logs.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard("Duration", _formatDuration(duration)),
              _buildStatCard("Volume", "$volume kg"),
              _buildStatCard("Sets", "$sets"),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
