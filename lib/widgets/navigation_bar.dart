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
  Workout? _currentWorkout;
  bool _isLoadingWorkout = true;

  late List<Widget> _pages;
  final List<PreferredSizeWidget> _appBar = [
    homeAppBar(),
    workoutAppBar(),
    profileAppBar(),
  ];

  @override
  void initState() {
    super.initState();
    _loadActiveWorkout();
    _initializePages();
  }

  void _initializePages() {
    _pages = [HomePage(), WorkoutPage(), ProfilePage()];
  }

  Future<void> _loadActiveWorkout() async {
    if (mounted) {
      setState(() {
        _isLoadingWorkout = true;
      });
    }

    try {
      final workout = await DatabaseService.instance.getUnfinishedWorkout();
      if (mounted) {
        setState(() {
          _currentWorkout = workout;
          _isLoadingWorkout = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentWorkout = null;
          _isLoadingWorkout = false;
        });
      }
    }
  }

  void reloadActiveWorkout() {
    _loadActiveWorkout();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _pages[_currentIndex]),
          // Show workout bar if we have an active workout
          if (!_isLoadingWorkout && _currentWorkout != null)
            resumeWorkoutPopup(
              context,
              themeData,
              _currentWorkout!,
              reloadActiveWorkout, // Pass the callback
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
