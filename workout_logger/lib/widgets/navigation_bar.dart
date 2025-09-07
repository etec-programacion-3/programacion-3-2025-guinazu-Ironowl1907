import 'package:flutter/material.dart';
import '../screens/home.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../screens/profile.dart';
import '../screens/settings.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), ProfilePage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue, // active color
        unselectedItemColor: Colors.grey, // inactive color
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
              color: _currentIndex == 1 ? Colors.blue : Colors.grey,
            ),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/account.svg',
              width: 24,
              height: 24,
              color: _currentIndex == 2 ? Colors.blue : Colors.grey,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
