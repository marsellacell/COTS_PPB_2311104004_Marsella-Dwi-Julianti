import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../task_detail/task_detail_page.dart';
import '../add_task/add_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TaskModel> allTasks = [];
  List<TaskModel> filteredTasks = [];
  bool isLoading = true;
  String currentFilter = 'SEMUA';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            currentFilter = 'SEMUA';
            filteredTasks = allTasks;
            break;
          case 1:
            currentFilter = 'BERJALAN';
            filteredTasks = allTasks
                .where((task) => task.status == 'BERJALAN')
                .toList();
            break;
          case 2:
            currentFilter = 'SELESAI';
            filteredTasks = allTasks
                .where((task) => task.status == 'SELESAI')
                .toList();
            break;
          case 3:
            currentFilter = 'TERLAMBAT';
            filteredTasks = allTasks
                .where((task) => task.status == 'TERLAMBAT')
                .toList();
            break;
        }
      });
    }
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final tasks = await TaskService.getAllTasks();
      setState(() {
        allTasks = tasks;
        _handleTabChange();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Tugas',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskPage()),
              ).then((_) => _loadTasks());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.labelSmall,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Berjalan'),
            Tab(text: 'Selesai'),
            Tab(text: 'Terlambat'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.paddingPage),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.marginCard,
                          ),
                          child: _buildTaskCard(task),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          ).then((_) => _loadTasks());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case 'SELESAI':
        statusColor = AppColors.statusDone;
        statusIcon = Icons.check_circle;
        break;
      case 'TERLAMBAT':
        statusColor = AppColors.statusLate;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = AppColors.statusRunning;
        statusIcon = Icons.pending;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
        ).then((_) => _loadTasks());
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingCard),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: task.isDone,
              onChanged: (value) async {
                try {
                  await TaskService.toggleTaskDone(task.id!, value ?? false);
                  _loadTasks();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating task: $e')),
                    );
                  }
                }
              },
              activeColor: AppColors.statusDone,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.h4.copyWith(
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isDone
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.course,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppSpacing.iconXs,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(task.deadline, style: AppTypography.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: AppSpacing.iconXs, color: statusColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    task.status,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingPage),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox,
                size: AppSpacing.iconXl * 2,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Tidak ada tugas',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                currentFilter == 'SEMUA'
                    ? 'Belum ada tugas yang ditambahkan'
                    : 'Tidak ada tugas dengan status $currentFilter',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
