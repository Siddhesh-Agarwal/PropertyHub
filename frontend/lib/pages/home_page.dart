import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/ui/loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name;
  UserMode? userMode;
  bool _loading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _loading = true;
    });
    try {
      var displayName = authService.value.userName;
      var mode = authService.value.userMode;
      if (mode == null || displayName == null) {
        authService.value.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        name = displayName;
        userMode = mode;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildBox({
    required BuildContext context,
    required String routeName,
    required IconData icon,
    required String text,
    Color color = Colors.grey,
  }) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              authService.value.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: (userMode == UserMode.admin) ? null : FloatingActionButton(
        child: const Icon(Icons.sos),
        onPressed: () {
          Navigator.pushNamed(context, '/sos');
        },
      ),
      body:
          _loading
              ? loading()
              : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        _errorMessage.isEmpty
                            ? [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                child: Text(
                                  'Welcome, ${name?.split(' ').first}!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (userMode == UserMode.admin)
                                _buildBox(
                                  context: context,
                                  routeName: '/properties',
                                  icon: Icons.house,
                                  text:
                                      (userMode == UserMode.admin)
                                          ? 'Manage Properties'
                                          : 'Properties',
                                  color: Colors.blue,
                                ),
                              if (userMode == UserMode.admin)
                                _buildBox(
                                  context: context,
                                  routeName: '/users',
                                  icon: Icons.people,
                                  text: 'Manage Users',
                                  color: Colors.brown,
                                ),
                              if (userMode == UserMode.user)
                                _buildBox(
                                  context: context,
                                  routeName: "/contract",
                                  icon: Icons.policy,
                                  text: "View Contract",
                                  color: Colors.purple,
                                ),
                              _buildBox(
                                context: context,
                                routeName: '/service',
                                icon: Icons.room_service,
                                text:
                                    (userMode == UserMode.admin)
                                        ? 'Service Requests'
                                        : 'Service',
                                color: Colors.green,
                              ),
                              _buildBox(
                                context: context,
                                routeName: '/feedback',
                                icon: Icons.comment,
                                text:
                                    (userMode == UserMode.admin)
                                        ? 'View Feedbacks'
                                        : 'Feedback',
                                color: Colors.deepOrange,
                              ),
                            ]
                            : [
                              const SizedBox(height: 20),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                  ),
                ),
              ),
    );
  }
}
