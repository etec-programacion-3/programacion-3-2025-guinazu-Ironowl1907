import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Pages for each tab
  final List<Widget> _pages = [
    const Center(child: Text("Home Page")),
    const Center(child: Text("Workout Page")),
    const Center(child: Text("Profile Page")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(title: const Text("Home")),
      body: _pages[_currentIndex],
    );
  }
}
