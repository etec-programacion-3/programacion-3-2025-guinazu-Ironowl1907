import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/screens/routine_create_page.dart';
import 'package:workout_logger/widgets/routine_card.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RoutineProvider>(context, listen: false).load();
    });
  }

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
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: provider.routines.length,
              itemBuilder: (BuildContext context, int index) {
                return routineCard(provider.routines[index], colorScheme);
              },
            ),
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
