import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';
import 'package:workout_logger/widgets/delete_confirmation.dart';

class MuscleGroupPage extends StatefulWidget {
  const MuscleGroupPage({super.key});

  @override
  State<MuscleGroupPage> createState() => _MuscleGroupPageState();
}

class _MuscleGroupPageState extends State<MuscleGroupPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MuscleGroupProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MuscleGroupProvider provider = context.watch<MuscleGroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Muscle Groups')),
      body: ListView.builder(
        itemCount: provider.muscleGroups.length,
        itemBuilder: (BuildContext context, int index) {
          return _muscleGroupCard(provider.muscleGroups[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditMuscleGroup(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _muscleGroupCard(MuscleGroup muscleGroup) {
    return ListTile(
      title: Text(muscleGroup.name),
      trailing: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'edit') {
            _addOrEditMuscleGroup(context, muscleGroup: muscleGroup);
          } else if (value == 'delete') {
            showDeleteConfirmation(
              context: context,
              body: 'Do you want to delete ${muscleGroup.name}?',

              title: 'Delete Muscle Group',
              onDelete: () {
                Navigator.of(context).pop();
                context.read<MuscleGroupProvider>().delete(muscleGroup);
              },
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: <Widget>[
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: <Widget>[
                Icon(Icons.delete),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addOrEditMuscleGroup(BuildContext context, {MuscleGroup? muscleGroup}) {
    final TextEditingController nameController = TextEditingController();
    if (muscleGroup != null) nameController.text = muscleGroup.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            muscleGroup == null ? 'Create Muscle Group' : 'Edit Muscle Group',
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Name',
              label: Text('Muscle Name'),
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
                  if (muscleGroup == null) {
                    Navigator.of(context).pop();
                    context.read<MuscleGroupProvider>().add(
                      MuscleGroup(name: name),
                    );
                  } else {
                    Navigator.of(context).pop();
                    context.read<MuscleGroupProvider>().update(
                      MuscleGroup(name: name, id: muscleGroup.id),
                    );
                  }
                }
              },
              child: Text(muscleGroup == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
