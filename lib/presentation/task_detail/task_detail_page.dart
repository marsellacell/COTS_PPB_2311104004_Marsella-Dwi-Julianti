import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/task_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../design_system/spacing.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailPage({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskModel currentTask;
  final TextEditingController _noteController = TextEditingController();
  bool isEditing = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
    _noteController.text = currentTask.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _toggleTaskDone() async {
    setState(() => isSaving = true);
    try {
      final updatedTask = await TaskService.toggleTaskDone(
        currentTask.id!,
        !currentTask.isDone,
      );
      setState(() {
        currentTask = updatedTask;
        isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentTask.isDone
                  ? 'Tugas ditandai selesai'
                  : 'Tugas ditandai belum selesai',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    setState(() => isSaving = true);
    try {
      final updatedTask = await TaskService.updateTaskNote(
        currentTask.id!,
        _noteController.text,
      );
      setState(() {
        currentTask = updatedTask;
        isEditing = false;
        isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (currentTask.status) {
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
          'Detail Tugas',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Status Card
            Container(
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
                          currentTask.title,
                          style: AppTypography.h3.copyWith(
                            decoration: currentTask.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusButton,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: AppSpacing.iconSm,
                              color: statusColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              currentTask.status,
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
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoRow(Icons.book, 'Mata Kuliah', currentTask.course),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Deadline',
                    currentTask.deadline,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Complete Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _toggleTaskDone,
                      icon: Icon(
                        currentTask.isDone
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: AppSpacing.iconMd,
                      ),
                      label: Text(
                        currentTask.isDone
                            ? 'Tandai Belum Selesai'
                            : 'Tandai Selesai',
                        style: AppTypography.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTask.isDone
                            ? AppColors.textSecondary
                            : AppColors.statusDone,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notes Section
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Catatan', style: AppTypography.h4),
                      if (!isEditing)
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: AppSpacing.iconMd,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() => isEditing = true);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isEditing)
                    Column(
                      children: [
                        TextField(
                          controller: _noteController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Tambahkan catatan...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInput,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInput,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        setState(() {
                                          isEditing = false;
                                          _noteController.text =
                                              currentTask.note ?? '';
                                        });
                                      },
                                child: Text(
                                  'Batal',
                                  style: AppTypography.button.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusButton,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _saveNote,
                                child: Text(
                                  'Simpan',
                                  style: AppTypography.button,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusButton,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Text(
                      currentTask.note?.isEmpty ?? true
                          ? 'Belum ada catatan'
                          : currentTask.note!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: currentTask.note?.isEmpty ?? true
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Metadata
            Container(
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
                  Text('Informasi Tambahan', style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.md),
                  if (currentTask.createdAt != null)
                    _buildMetaRow(
                      'Dibuat pada',
                      _formatDateTime(currentTask.createdAt!),
                    ),
                  if (currentTask.updatedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: _buildMetaRow(
                        'Diperbarui pada',
                        _formatDateTime(currentTask.updatedAt!),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Icon(icon, size: AppSpacing.iconMd, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
