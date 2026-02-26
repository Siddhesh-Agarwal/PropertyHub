import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String routeName;
  final IconData icon;
  final String text;
  final Color color;

  const DashboardCard({
    super.key,
    required this.routeName,
    required this.icon,
    required this.text,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
