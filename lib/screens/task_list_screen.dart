import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<ParseObject> tasks = [];

  Future<void> _fetchTasks() async {
    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('userId', user);

    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
      });
    }
  }

  Future<void> _deleteTask(ParseObject task) async {
    await task.delete();
    _fetchTasks();
  }

  Future<void> _toggleTaskStatus(ParseObject task) async {
    task.set('status', !(task.get('status') ?? false));
    await task.save();
    _fetchTasks();
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final user = await ParseUser.currentUser() as ParseUser;
              await user.logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.get('title')),
            subtitle: Text('Due: ${task.get('dueDate')}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(task.get('status') == true ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () => _toggleTaskStatus(task),
                ),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTask(task)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()));
          _fetchTasks();
        },
      ),
    );
  }
}
