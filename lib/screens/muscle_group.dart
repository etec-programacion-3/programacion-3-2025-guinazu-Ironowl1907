import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

class MuscleGroupPage extends StatelessWidget {
  const MuscleGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<MuscleGroupProvider>(
        builder:
            (
              BuildContext context,
              MuscleGroupProvider muscleGroupProvider,
              Widget? child,
            ) {
              final List<MuscleGroup> muscleGroups =
                  muscleGroupProvider.muscleGroups;
              return ListView.builder(
                itemCount: muscleGroups.length,
                itemBuilder: (BuildContext context, int index) {
                  final MuscleGroup muscleGroup = muscleGroups[index];
                  return ListTile(title: Text(muscleGroup.name));
                },
              );
            },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addMuscleGroupDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _addMuscleGroupDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();

  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Add Muscle Group'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Muscle Group Name',
          hintText: 'Enter muscle group name',
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Add'),
          onPressed: () {
            final String text = controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.of(context).pop(text);
            }
          },
        ),
      ],
    ),
  );

  if (result != null && result.isNotEmpty) {
    final MuscleGroupProvider provider = context.read<MuscleGroupProvider>();
    provider.add(MuscleGroup(name: result));
  }
  controller.dispose();
}
