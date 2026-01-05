import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  static const String _baseUrl =
      'https://rpblbedyqmnzpowbumzd.supabase.co/rest/v1/tasks';

  static const String _apiKey = 'MASUKKAN_SUPABASE_ANON_KEY_DISINI';

  static const Map<String, String> _headers = {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  Future<List<Task>> getTasks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl?select=*'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Task> addTask(Task task) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: jsonEncode(task.toJsonForPost()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data[0]);
    } else {
      throw Exception(
        'Failed to add task: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Task> updateTask(int id, Map<String, dynamic> updatedFields) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl?id=eq.$id'),
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data[0]);
    } else {
      throw Exception(
        'Failed to update task: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
