import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/providers/app_state_provider.dart';
import 'package:workout_logger/providers/workout_provider.dart';

import '../screens/home.dart';
import '../screens/profile.dart';
import '../screens/workout.dart';
import 'resume_workout_bar.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  late Future<void> _loadWorkoutFuture;

  @override
  void initState() {
    super.initState();
    _loadWorkoutFuture = _loadActiveWorkout();
  }

  Future<void> _loadActiveWorkout() async {
    final appState = context.read<AppStateProvider>();
    appState.setIsLoadingWorkout(true);

    try {
      final workout = await context
          .read<WorkoutProvider>()
          .getUnfinishedWorkout();
      appState.setCurrentWorkout(workout);
    } catch (_) {
      appState.setCurrentWorkout(null);
    } finally {
      appState.setIsLoadingWorkout(false);
    }
  }

  List<Widget> _buildPages() => [HomePage(), WorkoutPage(), ProfilePage()];
  List<PreferredSizeWidget> _buildAppBars() => [
    homeAppBar(),
    workoutAppBar(),
    profileAppBar(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final themeData = Theme.of(context);
    final pages = _buildPages();
    final appBars = _buildAppBars();

    return FutureBuilder(
      future: _loadWorkoutFuture,
      builder: (context, snapshot) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(child: pages[appState.navBarIndex]),
              // if (!appState.isLoadingWorkout && appState.currentWorkout != null)
              //   resumeWorkoutPopup(...)
            ],
          ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Theme(
              data: themeData.copyWith(
                appBarTheme: AppBarTheme(
                  backgroundColor: themeData.colorScheme.surface,
                  foregroundColor: themeData.colorScheme.onSurface,
                  elevation: 0,
                ),
              ),
              child: appBars[appState.navBarIndex],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: appState.navBarIndex,
            onTap: (index) => appState.setCurrentIndex(index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: themeData.colorScheme.surface,
            selectedItemColor: themeData.colorScheme.primary,
            unselectedItemColor: themeData.colorScheme.onSurfaceVariant,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/Exercise.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    appState.navBarIndex == 1
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
                    appState.navBarIndex == 2
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
      },
    );
  }
}
