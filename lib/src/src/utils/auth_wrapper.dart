import 'package:berita_garut/src/src/configs/app_routes.dart';
import 'package:berita_garut/src/src/provider/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
          return Container();
        }
        return child;
      },
    );
  }
}
