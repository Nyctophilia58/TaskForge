import 'package:client/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/user.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: ApiClient().getToken(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (tokenSnapshot.hasData && tokenSnapshot.data != null) {
          // Token exists → try to get user
          return FutureBuilder<User>(
            future: ref.read(authServiceProvider).getCurrentUser(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData) {
                final role = userSnapshot.data!.role;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/$role');
                });
              } else {
                // Invalid token → go to login
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              }

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        // No token → login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 80, color: Colors.blue),
                SizedBox(height: 20),
                Text('Task Platform', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}