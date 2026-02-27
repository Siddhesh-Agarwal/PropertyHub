import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/ui/dashboard_card.dart';
import '/ui/error.dart';
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

  @override
  Widget build(BuildContext context) {
    final adminCards = [
      const DashboardCard(
        routeName: '/properties',
        icon: Icons.house,
        text: 'Manage Properties',
        color: Colors.blue,
      ),
      const DashboardCard(
        routeName: '/users',
        icon: Icons.people,
        text: 'Manage Users',
        color: Colors.brown,
      ),
      const DashboardCard(
        routeName: '/admin/service',
        icon: Icons.room_service,
        text: 'Service Requests',
        color: Colors.green,
      ),
      const DashboardCard(
        routeName: '/admin/feedback',
        icon: Icons.comment,
        text: 'View Feedbacks',
        color: Colors.deepOrange,
      ),
      const DashboardCard(
        routeName: '/admin/sos',
        icon: Icons.sos,
        text: 'SOS Requests',
        color: Colors.red,
      ),
    ];

    final userCards = [
      const DashboardCard(
        routeName: "/contract",
        icon: Icons.policy,
        text: "View Contract",
        color: Colors.purple,
      ),
      const DashboardCard(
        routeName: '/service',
        icon: Icons.room_service,
        text: 'Service',
        color: Colors.green,
      ),
      const DashboardCard(
        routeName: '/feedback',
        icon: Icons.comment,
        text: 'Feedback',
        color: Colors.deepOrange,
      ),
    ];

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
      floatingActionButton:
          (userMode == UserMode.admin)
              ? null
              : FloatingActionButton(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                child: Text(
                                  'Welcome, ${name?.split(' ').first}!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (userMode == UserMode.admin)
                                ...adminCards
                              else
                                ...userCards,
                            ]
                            : [
                              ErrorView(
                                error: _errorMessage,
                                onRetry: _initializeData,
                              ),
                            ],
                  ),
                ),
              ),
    );
  }
}
