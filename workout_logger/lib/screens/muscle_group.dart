import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MuscleGroupPage extends StatefulWidget {
  const MuscleGroupPage({super.key});

  @override
  State<MuscleGroupPage> createState() => _MuscleGroupPageState();
}

class _MuscleGroupPageState extends State<MuscleGroupPage> {
  late Future<List<MuscleGroup>> _muscleGroupsFuture;

  @override
  void initState() {
    super.initState();
    _refreshMuscleGroups();
  }

  void _refreshMuscleGroups() {
    setState(() {
      _muscleGroupsFuture = DatabaseService.instance.getAllMuscleGroups();
    });
  }

  Future<void> _addMuscleGroupDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Muscle Group"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter name"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).pop(text);
              }
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final muscleGroup = MuscleGroup(name: result);
      await DatabaseService.instance.insertMuscleGroup(muscleGroup);
      _refreshMuscleGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Muscle Groups")),
      body: FutureBuilder<List<MuscleGroup>>(
        future: _muscleGroupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final muscleGroups = snapshot.data ?? [];

          if (muscleGroups.isEmpty) {
            return const Center(child: Text("No muscle groups yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: muscleGroups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = muscleGroups[index];
              return GestureDetector(
                onTap: () {
                  print("Taped $index");
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/edit.svg',
                          width: 24,
                          height: 24,
                          color: colorScheme.onPrimaryFixed,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMuscleGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
