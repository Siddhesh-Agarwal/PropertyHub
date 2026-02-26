import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String displayName = user['displayName'] ?? 'Unknown User';
    final String email = user['email'] ?? user['id'] ?? 'No Email';
    final String role = user['role']?.toString() ?? 'User';

    return ListTile(
      leading: CircleAvatar(child: const Icon(Icons.person)),
      title: Text(displayName),
      subtitle: Text(email),
      trailing: Badge(
        label: Text(role.toUpperCase()),
        backgroundColor: role == "Admin" ? Colors.blue : Colors.green,
      ),
    );
  }
}
