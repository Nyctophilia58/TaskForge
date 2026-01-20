import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleMode() {
    setState(() => isLogin = !isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isLogin
                  ? LoginPage(key: const ValueKey('login'), onToggle: toggleMode)
                  : RegisterPage(key: const ValueKey('register'), onToggle: toggleMode),
            ),
          ),
        ),
      ),
    );
  }
}