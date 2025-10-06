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
  List<MuscleGroup> selectedMuscles = <MuscleGroup>[];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Muscle')),
      body: Consumer<MuscleGroupProvider>(
        builder: (BuildContext context, MuscleGroupProvider provider, _) {
          final List<MuscleGroup> filteredMuscles = provider.muscleGroups.where(
            (MuscleGroup muscle) {
              final String nameLower = muscle.name.toLowerCase();
              final String searchLower = searchQuery.toLowerCase();
              return nameLower.contains(searchLower);
            },
          ).toList();

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Muscle',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMuscles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _muscleGroupCard(filteredMuscles[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _muscleGroupCard(MuscleGroup muscleGroup) {
    final bool isSelected = selectedMuscles.contains(muscleGroup);
    return ListTile(
      title: Text(muscleGroup.name),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              selectedMuscles.add(muscleGroup);
            } else {
              selectedMuscles.remove(muscleGroup);
            }
          });
        },
      ),
    );
  }
}

