import 'package:flutter/material.dart';
import '../screens/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/profile.dart';
import '../screens/workout.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/services/database_service.dart';
import 'resume_workout_bar.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;

  late Future<Workout?> _activeWorkout;

  Future<Workout?> loadActiveWorkout() {
    return DatabaseService.instance.getUnfinishedWorkout();
  }

  final List<Widget> _pages = const [HomePage(), WorkoutPage(), ProfilePage()];
  final List<PreferredSizeWidget> _appBar = [
    homeAppBar(),
    workoutAppBar(),
    profileAppBar(),
  ];

  @override
  void initState() {
    super.initState();
    _activeWorkout = loadActiveWorkout();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _pages[_currentIndex]),
          FutureBuilder<Workout?>(
            future: _activeWorkout,
            builder: (BuildContext context, AsyncSnapshot<Workout?> snapshot) {
              Workout? currentWorkout = snapshot.data;
              if (snapshot.connectionState == ConnectionState.done &&
                  currentWorkout != null) {
                return resumeWorkoutPopup(context, themeData, currentWorkout);
              }
              return Container();
            },
          ),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: themeData.colorScheme.surface,
              foregroundColor: themeData.colorScheme.onSurface,
              elevation: 0,
            ),
          ),
          child: _appBar[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: themeData.colorScheme.surface,
        selectedItemColor: themeData.colorScheme.primary,
        unselectedItemColor: themeData.colorScheme.onSurfaceVariant,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/Exercise.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _currentIndex == 1
                    ? themeData.colorScheme.primary
                    : themeData.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/account.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _currentIndex == 2
                    ? themeData.colorScheme.primary
                    : themeData.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
