import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/screens/routine_create_page.dart';
import 'package:workout_logger/widgets/routine_card.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      body: Consumer<RoutineProvider>(
        builder: (BuildContext context, RoutineProvider provider, _) {
          if (provider.routines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No routines added yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return routineCard(provider.routines[index], colorScheme);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const RoutineCreatorPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
