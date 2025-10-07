import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

class MuscleGroupSelector extends StatefulWidget {
  const MuscleGroupSelector({super.key});

  @override
  State<MuscleGroupSelector> createState() => _MuscleGroupSelectorState();
}

class _MuscleGroupSelectorState extends State<MuscleGroupSelector> {
  final List<MuscleGroup> selectedMuscleGroups = <MuscleGroup>[];

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
      appBar: AppBar(
        title: const Text('Select Muscle Groups'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(selectedMuscleGroups);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: provider.muscleGroups.isEmpty
          ? const Center(child: Text('No muscle groups available'))
          : ListView.builder(
              itemCount: provider.muscleGroups.length,
              itemBuilder: (BuildContext context, int index) {
                final MuscleGroup muscleGroup = provider.muscleGroups[index];
                final bool isSelected = selectedMuscleGroups.contains(
                  muscleGroup,
                );

                return CheckboxListTile(
                  title: Text(muscleGroup.name),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedMuscleGroups.add(muscleGroup);
                      } else {
                        selectedMuscleGroups.remove(muscleGroup);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}
