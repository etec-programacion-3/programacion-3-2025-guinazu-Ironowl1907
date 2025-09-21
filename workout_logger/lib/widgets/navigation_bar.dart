import 'package:flutter/material.dart';
import '../screens/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/profile.dart';
import '../screens/workout.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [HomePage(), WorkoutPage(), ProfilePage()];
  final List<PreferredSizeWidget> _appBar = [
    homeAppBar(),
    workoutAppBar(),
    profileAppBar(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(child: _pages[_currentIndex]),
          // Fixed popup at bottom - always visible above bottom nav
          resumeWorkoutPopup(context, colorScheme),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
            ),
          ),
          child: _appBar[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
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
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
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
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget resumeWorkoutPopup(BuildContext context, ColorScheme colorScheme) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2), // Shadow going upward
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Floating Space',
          style: TextStyle(color: colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
