import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

Dismissible muscleGroupCard(
  BuildContext context,
  MuscleGroup group,
  int index,
  ColorScheme colorScheme,
) {
  return Dismissible(
    key: ValueKey(group.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (_) {
      _deleteMuscleGroup(context, group);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${group.name} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              //TODO:  Could implement undo functionality here
            },
          ),
        ),
      );
    },
    child: GestureDetector(
      onTap: () => _editMuscleGroupDialog(context, group),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/edit.svg',
                width: 24,
                height: 24,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    ),
  );
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

Future<void> _deleteMuscleGroup(
  BuildContext context,
  MuscleGroup muscleGroup,
) async {
  context.read<MuscleGroupProvider>().delete(muscleGroup);
}

Future<void> _editMuscleGroupDialog(
  BuildContext context,
  MuscleGroup muscleGroup,
) async {
  final TextEditingController controller = TextEditingController(
    text: muscleGroup.name,
  );

  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Edit Muscle Group'),
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
          child: const Text('Save'),
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
    final MuscleGroup updatedGroup = MuscleGroup(
      id: muscleGroup.id,
      name: result,
    );
    context.read<MuscleGroupProvider>().update(updatedGroup);
  }
}

class MuscleGroupPage extends StatelessWidget {
  const MuscleGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<MuscleGroupProvider>(
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
                    return muscleGroupCard(
                      context,
                      muscleGroup,
                      index,
                      colorScheme,
                    );
                  },
                );
              },
        ),
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
