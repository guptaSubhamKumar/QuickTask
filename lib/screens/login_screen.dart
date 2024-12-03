import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final user = ParseUser(_emailController.text.trim(), _passwordController.text.trim(), null);
    var response = await user.login();

    if (response.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
    } else {
      _showErrorDialog(response.error!.message);
    }
  }

  Future<void> _signUp() async {
    final user = ParseUser(_emailController.text.trim(), _passwordController.text.trim(), _emailController.text.trim());
    var response = await user.signUp();

    if (response.success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
    } else {
      _showErrorDialog(response.error!.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuickTask Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(onPressed: _signUp, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
