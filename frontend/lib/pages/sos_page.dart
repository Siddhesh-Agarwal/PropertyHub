import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/db_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});
  static const sosNumbers = {
    'Police': '999',
    'Fire Department': '999',
    'Ambulance': '999',
  };

  void _logProblem(String title) {
    db.collection("sos").add({
      "title": title,
      "timestamp": DateTime.now(),
      'email': authService.value.user!.email,
      'name': authService.value.userName,
    });
  }

  void _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Widget _buildSosOption({
    required String title,
    required String phoneNumber,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _logProblem(title);
        _callNumber(phoneNumber);
      },
      child: Container(
        height: 150,
        width: double.infinity,
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
              title,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Emergency')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSosOption(
              title: 'Police',
              phoneNumber: sosNumbers['Police']!,
              icon: Icons.local_police,
              color: Colors.blue,
            ),
            _buildSosOption(
              title: 'Fire Department',
              phoneNumber: sosNumbers['Fire Department']!,
              icon: Icons.local_fire_department,
              color: Colors.red,
            ),
            _buildSosOption(
              title: 'Ambulance',
              phoneNumber: sosNumbers['Ambulance']!,
              icon: Icons.local_hospital,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
