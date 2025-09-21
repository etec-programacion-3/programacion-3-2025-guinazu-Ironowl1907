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
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
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
                // Fixed: use colorFilter instead of color
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

  Positioned resumeWorkoutPopup(BuildContext context, ColorScheme colorScheme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            // Added const
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: const [
            // Added const
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
