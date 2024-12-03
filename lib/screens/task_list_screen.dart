import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:intl/intl.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ParseObject> tasks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetchTasks();
  }

  Future<void> _checkSessionAndFetchTasks() async {
    setState(() {
      isLoading = true;
    });
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null || user.sessionToken == null) {
      _navigateToLogin();
      return;
    }
    final response = await ParseUser.getCurrentUserFromServer(user.sessionToken!);
    if (response!.success && response.result != null) {
      _fetchTasks();
    } else {
      _navigateToLogin();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchTasks() async {
    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('user', user);
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
      });
    }
  }

  Future<void> _deleteTask(ParseObject task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        isLoading = true;
      });
      final response = await task.delete();
      if (response.success) {
        _fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: ${response.error!.message}')),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _toggleTaskStatus(ParseObject task) async {
    setState(() {
      isLoading = true;
    });
    task.set('status', !(task.get('status') as bool));
    final response = await task.save();
    if (response.success) {
      _fetchTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task status updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task status: ${response.error!.message}')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final user = await ParseUser.currentUser() as ParseUser;
              await user.logout();
              _navigateToLogin();
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final formattedDate = DateFormat.yMMMd().format(task.get<DateTime>('dueDate')!);
                    return Card(
                      color: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          task.get<String>('title')!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Due Date: $formattedDate',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                task.get('status') == true ? Icons.check_box : Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                              onPressed: () => _toggleTaskStatus(task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteTask(task),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskScreen(task: task),
                            ),
                          ).then((value) {
                            if (value == true) {
                              _fetchTasks();
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          ).then((value) => _fetchTasks());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}