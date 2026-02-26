import 'package:flutter/material.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';

class _BaseGuard extends StatelessWidget {
  final Widget child;
  final UserMode requiredMode;

  const _BaseGuard({required this.child, required this.requiredMode});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthService>(
      valueListenable: authService,
      builder: (context, auth, _) {
        final user = auth.user;
        final mode = auth.userMode;

        if (user == null) {
          // Not logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (mode != requiredMode) {
          // Authorized but wrong role
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}

class AdminGuard extends StatelessWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _BaseGuard(requiredMode: UserMode.admin, child: child);
  }
}

class UserGuard extends StatelessWidget {
  final Widget child;
  const UserGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _BaseGuard(requiredMode: UserMode.user, child: child);
  }
}
