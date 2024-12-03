import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Parse Server
  const appId = 'XwlsJ9P8DUerulwMIHjxqIUnitwsBqWKm6tiovsJ';
  const clientKey = 'ffmUW3w7F5CJyhJfA0uwhcKbuW1KmujvXVOzZYYz';
  const serverUrl = 'https://parseapi.back4app.com';
  await Parse().initialize(appId, serverUrl, clientKey: clientKey, autoSendSessionId: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/add-task': (context) => const AddTaskScreen(),
        '/edit-task': (context) => EditTaskScreen(task: ParseObject('Task')),
      },
    );
  }
}