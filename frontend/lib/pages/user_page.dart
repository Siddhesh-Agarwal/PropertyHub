import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final int _usersPerPage = 20;
  int _currentPage = 0;
  bool _loading = false;
  UserMode? _userMode;
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.value.userMode != UserMode.admin) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      var userMode = authService.value.userMode;
      if (userMode == null) {
        authService.value.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        _userMode = userMode;
      });
      final querySnapshot = await userService.getUsers();
      _users =
          querySnapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      _filteredUsers = _getUsersForPage(_currentPage);
    } catch (e) {
      if (!mounted) return;
      errorSnack(context, "Error loading users. Please try again.");
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _getUsersForPage(int page) {
    final startIndex = page * _usersPerPage;
    final endIndex = (startIndex + _usersPerPage).clamp(0, _users.length);
    return _users.sublist(startIndex, endIndex);
  }

  void _filterUsers(String query) {
    setState(() {
      _currentPage = 0;
      _filteredUsers =
          query.isEmpty
              ? _getUsersForPage(_currentPage)
              : _users
                  .where(
                    (user) => user["displayName"]?.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  )
                  .toList();
    });
  }

  void _loadNextPage() {
    if (_searchController.text.isNotEmpty) {
      return;
    }

    setState(() {
      if (_hasMoreUsers()) {
        _currentPage++;
        final newUsers = _getUsersForPage(_currentPage);
        if (newUsers.isNotEmpty) {
          _filteredUsers.addAll(newUsers);
        }
      }
    });
  }

  bool _hasMoreUsers() {
    return _searchController.text.isEmpty &&
        _filteredUsers.length < _users.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_userMode != UserMode.admin) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/users/add');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body:
          _loading
              ? loading()
              : RefreshIndicator.adaptive(
                onRefresh: () async {
                  _searchController.clear();
                  await _loadUsers();
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Users',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _filterUsers,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            _filteredUsers.length + (_hasMoreUsers() ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _filteredUsers.length) {
                            _loadNextPage();
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final user = _filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: const Icon(Icons.person),
                            ),
                            title: Text(user['displayName']!),
                            subtitle: Text(user['email']!),
                            trailing: Badge(
                              label: Text(
                                user["role"].toString().toUpperCase(),
                              ),
                              backgroundColor:
                                  user["role"] == "Admin"
                                      ? Colors.blue
                                      : Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
