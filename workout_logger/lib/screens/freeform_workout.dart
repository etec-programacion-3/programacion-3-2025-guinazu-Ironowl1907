import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';

class FreeFormWorkoutPage extends StatefulWidget {
  const FreeFormWorkoutPage({super.key});

  @override
  State<FreeFormWorkoutPage> createState() => _FreeFormWorkoutPageState();
}

class _FreeFormWorkoutPageState extends State<FreeFormWorkoutPage> {
  Workout? _runningWorkout;
  List<WorkoutLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _restoreWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log Workout")),
      body: _runningWorkout == null ? _freeFormWorkout() : _routineWorkout(),
    );
  }

  Widget _routineWorkout() {
    return Placeholder();
  }

  Future<void> _restoreWorkout() async {
    final db = DatabaseService.instance;
    final workouts = await db.getAllWorkouts();
    final active = workouts.firstWhere(
      (w) => w.endedAt == null,
      orElse: () => null as Workout,
    );

    if (active != null) {
      final logs = await db.getWorkoutLogsByWorkout(active.id!);
      setState(() {
        _runningWorkout = active;
        _logs = logs;
      });
    }
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
    final db = DatabaseService.instance;
    await db.endWorkout(_runningWorkout!.id!);

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
    return Column(
      children: [
        workoutStatus(),
        const SizedBox(height: 20),
        if (_runningWorkout == null)
          ElevatedButton(
            onPressed: _startWorkout,
            child: const Text("Start Workout"),
          )
        else
          ElevatedButton(
            onPressed: () => _addSet(1, 10, 50.0), // dummy exercise example
            child: const Text("Add Set"),
          ),
        if (_runningWorkout != null)
          ElevatedButton(
            onPressed: _endWorkout,
            child: const Text("End Workout"),
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
