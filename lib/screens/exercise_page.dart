import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';
import 'package:workout_logger/screens/muscle_selector.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditExercise(context, null);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: provider.exercises.length,
          itemBuilder: (BuildContext context, int index) {
            return _exerciseCard(provider.exercises[index], context);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExerciseProvider>(context, listen: false).load();
    });
  }

  void _addOrEditExercise(BuildContext context, Exercise? exercise) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionConroller = TextEditingController();
    if (exercise != null) {
      nameController.text = exercise.name;
      descriptionConroller.text = exercise.description ?? '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(exercise == null ? 'Create Exercise' : 'Edit Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                    label: Text('Exercise Name'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionConroller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Description',
                    label: Text('Description'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Muscle Groups'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const MuscleGroupSelector(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  if (exercise == null) {
                    Navigator.of(context).pop();
                    context.read<ExerciseProvider>().add(Exercise(name: name));
                  } else {
                    Navigator.of(context).pop();
                    context.read<ExerciseProvider>().update(
                      Exercise(name: name, id: exercise.id),
                    );
                  }
                }
              },
              child: Text(exercise == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _exerciseCard(Exercise exercise, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _addOrEditExercise(context, exercise);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox.square(dimension: 8),
                  Row(children: <Widget>[_muscleGroupChip(context, exercise)]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _muscleGroupChip(BuildContext context, Exercise exercise) {
    return FutureBuilder<MuscleGroup?>(
      future: context.read<MuscleGroupProvider>().get(
        exercise.muscleGroupId ?? 0,
      ),
      builder:
          (BuildContext context, AsyncSnapshot<MuscleGroup?> asyncSnapshot) {
            String label;
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              label = 'Loading...';
            } else if (asyncSnapshot.hasError) {
              label = 'Error';
            } else if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
              label = asyncSnapshot.data!.name;
            } else {
              label = 'None';
            }

            return Chip(label: Text(label));
          },
    );
  }
}
