import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/auth_services.dart';
import '/services/user_service.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool _loading = false;
  String? get email => authService.value.user!.email;
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => _loading = true);
    try {
      final data = await userService.getUser(email: email!);
      if (data == null) {
        throw Exception("Error fetching user data");
      }
      setState(() {
        userData = data;
      });
    } catch (e) {
      if (!mounted) return;
      errorSnack(context, "Error fetching user data: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/profile/edit", arguments: email);
            },
            icon: Icon(Icons.edit_square),
          ),
          IconButton(
            onPressed: () {
              authService.value.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body:
          _loading
              ? loading()
              : RefreshIndicator.adaptive(
                onRefresh: fetchUserData,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Profile Picture (Placeholder)
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Display Name
                    _buildProfileInfo(
                      label: 'Display Name',
                      value: userData!['displayName']?.toString() ?? 'N/A',
                      icon: Icons.person_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Phone Number
                    _buildProfileInfo(
                      label: 'Phone Number',
                      value: userData!['phoneNumber'] ?? 'N/A',
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Email ID
                    _buildProfileInfo(
                      label: 'Email ID',
                      value: userData!['email'] ?? 'N/A',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildProfileInfo(
                      label: 'Qatar ID',
                      value: userData!['qatarId'] ?? 'N/A',
                      icon: Icons.credit_card_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Date of Birth
                    _buildProfileInfo(
                      label: 'Date of Birth',
                      value:
                          userData!['dateOfBirth'] != null
                              ? DateFormat(
                                'dd-MM-yyyy',
                              ).format(userData!['dateOfBirth'].toDate())
                              : 'N/A',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Gender
                    _buildProfileInfo(
                      label: 'Gender',
                      value: userData!['gender'] ?? 'N/A',
                      icon: Icons.transgender_outlined,
                    ),
                  ],
                ),
              ),
    );
  }

  // Helper method to build profile information rows
  Widget _buildProfileInfo({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
