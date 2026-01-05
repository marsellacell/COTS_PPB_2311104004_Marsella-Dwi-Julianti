import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../task_list/task_list_page.dart';
import '../add_task/add_task_page.dart';
import '../task_detail/task_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TaskModel> allTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final tasks = await TaskService.getAllTasks();
      setState(() {
        allTasks = tasks;
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

  int get runningCount =>
      allTasks.where((task) => task.status == 'BERJALAN').length;
  int get doneCount =>
      allTasks.where((task) => task.status == 'SELESAI').length;
  int get lateCount =>
      allTasks.where((task) => task.status == 'TERLAMBAT').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.paddingPage),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text('Selamat Datang! 👋', style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kelola tugas Anda dengan lebih efisien',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Tugas',
                            allTasks.length.toString(),
                            AppColors.primary,
                            Icons.assignment,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Selesai',
                            doneCount.toString(),
                            AppColors.statusDone,
                            Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Berjalan',
                            runningCount.toString(),
                            AppColors.statusRunning,
                            Icons.pending,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Terlambat',
                            lateCount.toString(),
                            AppColors.statusLate,
                            Icons.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick Actions
                    Text('Aksi Cepat', style: AppTypography.h4),
                    const SizedBox(height: AppSpacing.md),
                    _buildQuickActionButton(
                      'Lihat Semua Tugas',
                      Icons.list,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaskListPage(),
                          ),
                        ).then((_) => _loadTasks());
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildQuickActionButton(
                      'Tambah Tugas Baru',
                      Icons.add_circle,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTaskPage(),
                          ),
                        ).then((_) => _loadTasks());
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Recent Tasks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tugas Terbaru', style: AppTypography.h4),
                        if (allTasks.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TaskListPage(),
                                ),
                              ).then((_) => _loadTasks());
                            },
                            child: Text(
                              'Lihat Semua',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (allTasks.isEmpty)
                      _buildEmptyState()
                    else
                      ...allTasks
                          .take(3)
                          .map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.marginCard,
                              ),
                              child: _buildTaskCard(task),
                            ),
                          ),
                  ],
                ),
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

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconLg),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.h2.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingCard),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppSpacing.iconSm,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    Color statusColor;
    switch (task.status) {
      case 'SELESAI':
        statusColor = AppColors.statusDone;
        break;
      case 'TERLAMBAT':
        statusColor = AppColors.statusLate;
        break;
      default:
        statusColor = AppColors.statusRunning;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTypography.h4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusButton,
                    ),
                  ),
                  child: Text(
                    task.status,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(task.course, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.sm),
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: AppSpacing.iconXl * 2,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada tugas',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tambahkan tugas pertama Anda',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
