import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/ui/button.dart';
import '/ui/dropdown.dart';
import '/ui/snackbar.dart';
import '/utils/utils.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'User';
  final List<String> _roles = ['User', 'Admin'];
  UserService userService = UserService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await userService.addUser(
          displayName: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          role: _selectedRole,
        );
        if (!mounted) return;
        successSnack(context, 'User added successfully!');
        Navigator.pop(context);
      } catch (e) {
        errorSnack(context, 'Error adding user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Dropdown(
                items: _roles,
                value: _selectedRole,
                label: 'Select Role',
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              OutlineButton(onPressed: _addUser, label: 'Add User'),
            ],
          ),
        ),
      ),
    );
  }
}
