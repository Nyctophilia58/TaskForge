import 'package:flutter/material.dart';
import '../../../shared/models/user.dart';
import '../data/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginPage({super.key, required this.onToggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Navigate based on role
      if (!mounted) return;

      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (user.role == 'buyer') {
        Navigator.pushReplacementNamed(context, '/buyer');
      } else if (user.role == 'developer') {
        Navigator.pushReplacementNamed(context, '/developer');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('401')
              ? 'Invalid email or password'
              : 'Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.blue[700]),
          const SizedBox(height: 20),
          const Text(
            'Welcome Back!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Login to continue',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter email';
              if (!value.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter password';
              if (value.length < 6) return 'Password too short';
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          // Toggle to Register
          TextButton(
            onPressed: widget.onToggle,
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}