import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class EditTaskScreen extends StatefulWidget {
  final ParseObject task;
  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  DateTime? _dueDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.get<String>('title')!;
    _dueDate = widget.task.get<DateTime>('dueDate');
  }

  Future<void> _updateTask() async {
    if (titleController.text.isEmpty || _dueDate == null) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() {
      isLoading = true;
    });

    widget.task
      ..set('title', titleController.text)
      ..set('dueDate', DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, 12)); // Set time to noon to avoid timezone issues

    final response = await widget.task.save();
    setState(() {
      isLoading = false;
    });

    if (response.success) {
      Navigator.pop(context, true);
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove the back button
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const Text(
                    //   'QuickTask',
                    //   style: TextStyle(
                    //     fontSize: 40,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    const Text(
                      'Edit your task',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white24,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _dueDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      controller: TextEditingController(
                        text: _dueDate != null ? _dueDate!.toLocal().toString().split(' ')[0] : '',
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Update Task', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}