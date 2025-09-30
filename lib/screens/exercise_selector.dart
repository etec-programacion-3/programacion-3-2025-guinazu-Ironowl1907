import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_provider.dart';

class ExerciseSelectionProvider extends ChangeNotifier {
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<Exercise> filterExercises(List<Exercise> exercises) {
    if (_searchQuery.isEmpty) {
      return exercises;
    }
    return exercises.where((Exercise exercise) {
      final String name = exercise.name.toLowerCase();
      final String description = exercise.description?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || description.contains(_searchQuery);
    }).toList();
  }
}

class ExerciseSelectionPage extends StatelessWidget {
  const ExerciseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseSelectionProvider(),
      child: const ExerciseSelectionView(),
    );
  }
}

class ExerciseSelectionView extends StatelessWidget {
  const ExerciseSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(padding: EdgeInsets.all(8.0), child: SearchBar()),
        ),
      ),
      body: const ExerciseList(),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseSelectionProvider searchProvider =
        Provider.of<ExerciseSelectionProvider>(context);
    final String searchQuery = searchProvider.searchQuery;

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search exercises...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchProvider.clearSearch();
                },
              )
            : null,
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (String value) {
        searchProvider.updateSearchQuery(value);
      },
    );
  }
}

class ExerciseList extends StatelessWidget {
  const ExerciseList({super.key});

  @override
  Widget build(BuildContext context) {
    final ExerciseProvider exerciseProvider = context.watch<ExerciseProvider>();
    final ExerciseSelectionProvider searchProvider =
        Provider.of<ExerciseSelectionProvider>(context);

    final List<Exercise> exercises = exerciseProvider.exercises;
    final List<Exercise> filteredExercises = searchProvider.filterExercises(
      exercises,
    );

    if (filteredExercises.isEmpty) {
      return EmptyState(searchQuery: searchProvider.searchQuery);
    }

    return ListView.builder(
      itemCount: filteredExercises.length,
      itemBuilder: (BuildContext context, int index) {
        final Exercise exercise = filteredExercises[index];
        return ExerciseListItem(exercise: exercise);
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  final String searchQuery;

  const EmptyState({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No exercises available'
                : 'No exercises found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;

  const ExerciseListItem({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
          title: Text(
            exercise.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: exercise.description != null
              ? Text(
                  exercise.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Return the selected exercise
            Navigator.pop(context, exercise);
          },
        ),
      ),
    );
  }
}
