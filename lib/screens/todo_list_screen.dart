import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoListScreen extends StatefulWidget {
  final String token;

  TodoListScreen({required this.token});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<dynamic> _tasks = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  void _fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse('https://7760-122-160-152-83.ngrok-free.app/todos'),
        headers: {'Authorization': widget.token},
      );

      if (response.statusCode == 200) {
        setState(() {
          _tasks = json.decode(response.body);
          _isLoading = false; // Stop loading
        });
      } else {
        _handleError('Failed to load todos: ${response.body}');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _addTodo() async {
    if (_taskController.text.isEmpty) return; // Prevent empty task submission

    try {
      final response = await http.post(
        Uri.parse('https://7760-122-160-152-83.ngrok-free.app/todos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': widget.token,
        },
        body: json.encode({'task': _taskController.text}),
      );

      if (response.statusCode == 201) {
        _fetchTodos(); // Refresh todo list
        _taskController.clear(); // Clear the input field
      } else {
        _handleError('Failed to add task: ${response.body}');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://7760-122-160-152-83.ngrok-free.app/todos/$id'),
        headers: {'Authorization': widget.token},
      );

      if (response.statusCode == 204) {
        _fetchTodos(); // Refresh todo list
      } else {
        _handleError('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false; // Stop loading if there's an error
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/'); // Redirect to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout button
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(task['task']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTodo(task['_id']),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: InputDecoration(labelText: 'New Task'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addTodo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
