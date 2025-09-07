import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profile Page"));
  }
}

PreferredSizeWidget profileAppBar() {
  return AppBar(title: Text("Profile"));
}
