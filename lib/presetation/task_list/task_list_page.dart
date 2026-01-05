import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService _service = TaskService();
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _service.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data'));
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(task.title, style: AppTextStyle.title),
                  subtitle: Text(
                    '${task.course} • ${task.deadline}',
                    style: AppTextStyle.body,
                  ),
                  trailing: Icon(
                    task.isDone ? Icons.check_circle : Icons.pending,
                    color: task.isDone ? Colors.green : Colors.orange,
                  ),
                  onTap: () {
                    // Next: Detail Task
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
