import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _deadline;
  String _status = 'BERJALAN';

  bool _isLoading = false;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih deadline terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final task = Task(
        id: 0,
        title: _titleController.text,
        course: _courseController.text,
        note: _noteController.text,
        deadline: _deadline!.toIso8601String().split('T')[0],
        status: _status,
        isDone: false,
      );

      final addedTask = await _taskService.addTask(task);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tugas "${addedTask.title}" berhasil ditambahkan!'),
        ),
      );

      Navigator.pop(context, addedTask);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan tugas: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Tugas'),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Course'),
                validator: (v) => v!.isEmpty ? 'Course wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _deadline == null
                      ? 'Pilih Deadline'
                      : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'BERJALAN', child: Text('BERJALAN')),
                  DropdownMenuItem(value: 'SELESAI', child: Text('SELESAI')),
                  DropdownMenuItem(
                    value: 'TERLAMBAT',
                    child: Text('TERLAMBAT'),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('Tambah Tugas'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
