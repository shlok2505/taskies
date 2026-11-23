import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  Color get _color => switch (task.priority) {
    Priority.high => AppColors.high,
    Priority.medium => AppColors.medium,
    Priority.low => AppColors.low,
  };

  String get _label => switch (task.priority) {
    Priority.high => 'High',
    Priority.medium => 'Medium',
    Priority.low => 'Low',
  };

  IconData get _icon => switch (task.priority) {
    Priority.high => Icons.warning_amber_rounded,
    Priority.medium => Icons.remove_circle_outline,
    Priority.low => Icons.arrow_downward_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;
    final overdue = !done && task.dueDate.isBefore(DateTime.now());

    return Container(
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: done ? AppColors.muted : _color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: onToggle,
                            child: Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 28,
                              color: done ? AppColors.low : AppColors.muted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: done ? AppColors.muted : null,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: overdue
                                          ? AppColors.high
                                          : AppColors.primaryLight,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatDue(task.dueDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: overdue
                                            ? AppColors.high
                                            : AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _color.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _color.withAlpha(90)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_icon, size: 14, color: _color),
                                const SizedBox(width: 4),
                                Text(
                                  _label,
                                  style: TextStyle(fontSize: 12, color: _color),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
