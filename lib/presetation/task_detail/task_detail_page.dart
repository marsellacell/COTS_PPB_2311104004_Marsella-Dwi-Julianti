import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  late TextEditingController _noteController;
  bool _isLoading = false;
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _noteController = TextEditingController(text: _task.note);
  }

  Future<void> _updateNote() async {
    setState(() => _isLoading = true);

    try {
      final updatedTask = await _taskService.updateTask(_task.id, {
        'note': _noteController.text,
      });

      setState(() => _task = updatedTask);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update catatan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);

    try {
      final bool newIsDone = !_task.isDone;
      final String newStatus = newIsDone ? 'SELESAI' : 'BERJALAN';

      final updatedTask = await _taskService.updateTask(_task.id, {
        'is_done': newIsDone,
        'status': newStatus,
      });

      setState(() => _task = updatedTask);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status diubah ke $newStatus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update status: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Tugas: ${_task.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Text(
                    'Course: ${_task.course}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Deadline: ${_task.deadline}'),
                  const SizedBox(height: 8),
                  Text('Status: ${_task.status}'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _updateNote,
                        child: const Text('Update Catatan'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _toggleStatus,
                        child: Text(
                          _task.isDone
                              ? 'Tandai Belum Selesai'
                              : 'Tandai Selesai',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
