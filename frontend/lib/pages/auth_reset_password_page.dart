import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/ui/button.dart';
import '/ui/snackbar.dart';
import '/utils/utils.dart';

class AuthResetPasswordPage extends StatefulWidget {
  const AuthResetPasswordPage({super.key});

  @override
  State<AuthResetPasswordPage> createState() => _AuthResetPasswordPageState();
}

class _AuthResetPasswordPageState extends State<AuthResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> overridePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await authService.value.resetPassword(email: _emailController.text.trim());
        if (!mounted) return;
        successSnack(context, 'Password reset email sent');
      } catch (e) {
        if (!mounted) return;
        errorSnack(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                "Enter your email to reset your password.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutlineButton(
                onPressed: overridePassword,
                label: 'Reset Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
