import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home Page"));
  }
}

PreferredSizeWidget homeAppBar() {
  return AppBar(
    title: Text("Home"),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Container(color: Colors.grey.shade300, height: 1.0),
    ),
  );
}
