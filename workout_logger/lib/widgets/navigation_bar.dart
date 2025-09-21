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
      body: Stack(
        children: [
          // Main body content with bottom padding
          Padding(
            padding: EdgeInsets.only(bottom: 100), // Space for floating widget
            child: _pages[_currentIndex],
          ),

          resumeWorkoutPopup(context, colorScheme),
        ],
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: colorScheme.surface, // app bar bg
              foregroundColor: colorScheme.onSurface, // title & icons
              elevation: 0,
            ),
          ),
          child: _appBar[_currentIndex],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface, // 🔹 themed background
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
              color: _currentIndex == 1
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/account.svg',
              width: 24,
              height: 24,
              color: _currentIndex == 2
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Positioned resumeWorkoutPopup(BuildContext context, ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Floating Space',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}
