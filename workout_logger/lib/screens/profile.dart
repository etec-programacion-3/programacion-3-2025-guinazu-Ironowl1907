import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0), // less padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),

          // Dashboard Menu
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 28,
              crossAxisSpacing: 28,
              childAspectRatio: 4.0,
              children: const [
                _DashboardButton(label: "Muscle Groups"),
                _DashboardButton(label: "Exercises"),
                _DashboardButton(label: "Routines"),
                _DashboardButton(label: "Progress"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Dashboard Button
class _DashboardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DashboardButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        textStyle: const TextStyle(fontSize: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // smaller rounded corners
        ),
      ),
      onPressed: onPressed ?? () => print(label),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

PreferredSizeWidget profileAppBar() {
  return AppBar(
    title: Text("Profile"),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Container(color: Colors.grey.shade300, height: 1.0),
    ),
  );
}
