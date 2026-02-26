import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: const Icon(Icons.person)),
      title: Text(user['displayName']!),
      subtitle: Text(user['email']!),
      trailing: Badge(
        label: Text(user["role"].toString().toUpperCase()),
        backgroundColor: user["role"] == "Admin" ? Colors.blue : Colors.green,
      ),
    );
  }
}
