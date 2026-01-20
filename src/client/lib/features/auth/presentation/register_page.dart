import 'package:flutter/material.dart';
import '../data/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onToggle;
  const RegisterPage({super.key, required this.onToggle});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  String _selectedRole = 'buyer'; // default
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Logging in...')),
      );

      // Navigate based on role
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (user.role == 'buyer') {
        Navigator.pushReplacementNamed(context, '/buyer');
      } else {
        Navigator.pushReplacementNamed(context, '/developer');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add, size: 80, color: Colors.green[700]),
          const SizedBox(height: 20),
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Join as a buyer or developer', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
            v != _passwordController.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 20),

          // Role Selection
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'I am a...',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'buyer', child: Text('Buyer (Post tasks)')),
              DropdownMenuItem(value: 'developer', child: Text('Developer (Complete tasks)')),
            ],
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          TextButton(
            onPressed: widget.onToggle,
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}