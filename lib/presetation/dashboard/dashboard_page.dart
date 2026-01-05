import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';
import '../task_list/task_list_page.dart';
import '../add_task/add_task_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang 👋', style: AppTextStyle.title),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Kelola tugas perkuliahan kamu dengan mudah',
              style: AppTextStyle.body,
            ),
            const SizedBox(height: AppSpacing.l),

            // Card Daftar Tugas
            _DashboardCard(
              title: 'Daftar Tugas',
              subtitle: 'Lihat semua tugas',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskListPage()),
                );
              },
            ),

            const SizedBox(height: AppSpacing.m),

            // Card Tambah Tugas
            _DashboardCard(
              title: 'Tambah Tugas',
              subtitle: 'Tambahkan tugas baru',
              icon: Icons.add_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(width: AppSpacing.m),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.title),
                  const SizedBox(height: AppSpacing.s),
                  Text(subtitle, style: AppTextStyle.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
