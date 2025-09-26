import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/screens/home.dart';
import 'package:workout_logger/screens/profile.dart';
import 'package:workout_logger/screens/workout.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class AppNavigation extends StatelessWidget {
  AppNavigation({super.key});

  final List<Widget> _bodyWidgets = <Widget>[
    const HomePage(),
    const WorkoutPage(),
    const ProfilePage(),
  ];
  final List<PreferredSizeWidget> _topBars = <PreferredSizeWidget>[
    homeAppBar(),
    workoutAppBar(),
    profileAppBar(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Consumer<NavigationProvider>(
      builder:
          (
            BuildContext context,
            NavigationProvider navigationProvider,
            Widget? child,
          ) {
            return Scaffold(
              appBar: _topBars[navigationProvider._currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: navigationProvider.currentIndex,
                onTap: (int index) => navigationProvider.setCurrentIndex(index),
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/Exercise.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        navigationProvider.currentIndex == 1
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Workout',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/account.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        navigationProvider.currentIndex == 2
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
              // You'll need to add body content here
              body: _bodyWidgets[navigationProvider.currentIndex],
            );
          },
    );
  }
}
