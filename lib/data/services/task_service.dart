import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  static const String baseUrl = 'https://rpblbedyqmnzpowbumzd.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwYmxiZWR5cW1uenBvd2J1bXpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMjcxMjYsImV4cCI6MjA3MzcwMzEyNn0.QaMJlyqhZcPorbFUpImZAynz3o2l0xDfq_exf2wUrTs';

  // Headers untuk setiap request
  static Map<String, String> get _headers => {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
    'Content-Type': 'application/json',
  };

  // 1. Get All Tasks
  static Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/tasks?select=*'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 2. Get Tasks by Status
  static Future<List<TaskModel>> getTasksByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/tasks?select=*&status=eq.$status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 3. Add New Task
  static Future<TaskModel> addTask(TaskModel task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rest/v1/tasks'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return TaskModel.fromJson(data.first);
      } else {
        throw Exception('Failed to add task');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 4. Update Task
  static Future<TaskModel> updateTask(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/rest/v1/tasks?id=eq.$id'),
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return TaskModel.fromJson(data.first);
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 5. Toggle Task Done Status
  static Future<TaskModel> toggleTaskDone(int id, bool isDone) async {
    final updates = {
      'is_done': isDone,
      'status': isDone ? 'SELESAI' : 'BERJALAN',
    };
    return await updateTask(id, updates);
  }

  // 6. Update Task Note
  static Future<TaskModel> updateTaskNote(int id, String note) async {
    final updates = {'note': note};
    return await updateTask(id, updates);
  }
}
