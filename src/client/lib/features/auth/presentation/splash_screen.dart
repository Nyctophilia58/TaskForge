import 'package:client/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const Duration minimumSplashDuration = Duration(seconds: 3); // ← Set your desired time

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startTime = DateTime.now();

    return FutureBuilder<String?>(
      future: ApiClient().getToken(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
          return _buildSplash();
        }

        if (tokenSnapshot.hasData && tokenSnapshot.data != null) {
          return FutureBuilder<User>(
            future: Future.wait([
              ref.read(authServiceProvider).getCurrentUser(),
              Future.delayed(minimumSplashDuration - DateTime.now().difference(startTime)),
            ]).then((results) => results[0] as User),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildSplash();
              }

              if (userSnapshot.hasData) {
                final role = userSnapshot.data!.role;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/$role');
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              }

              return _buildSplash();
            },
          );
        }

        // No token
        return FutureBuilder(
          future: Future.delayed(minimumSplashDuration - DateTime.now().difference(startTime)),
          builder: (context, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
            return _buildSplash();
          },
        );
      },
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading_animation.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 40),
            const Text(
              'TaskFlow',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}