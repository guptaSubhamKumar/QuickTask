import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;

  Future<void> _saveTask() async {
    final user = await ParseUser.currentUser() as ParseUser;
    final task = ParseObject('Task')
      ..set('title', _titleController.text)
      ..set('dueDate', _dueDate)
      ..set('status', false)
      ..set('userId', user);

    await task.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Task Title')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _dueDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
              },
              child: Text(_dueDate == null ? 'Select Due Date' : 'Due Date: $_dueDate'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: const Text('Save Task')),
          ],
        ),
      ),
    );
  }
}
