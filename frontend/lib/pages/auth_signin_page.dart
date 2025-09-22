import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/ui/button.dart';
import '/ui/snackbar.dart';
import '/utils/utils.dart';

class AuthSigninPage extends StatefulWidget {
  const AuthSigninPage({super.key});

  @override
  State<AuthSigninPage> createState() => _AuthSigninPageState();
}

class _AuthSigninPageState extends State<AuthSigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> submitForm() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.value.signIn(email: email.trim(), password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      errorSnack(context, e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Text(
                  "Welcome Back to $appName!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    OutlineButton(onPressed: submitForm, label: "Login"),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: const Text("Forgot your password? Reset it."),
              ),
              // const SizedBox(height: 2),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
