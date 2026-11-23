import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';
import '../widgets/skyline_background.dart';

enum TaskFilter { all, incomplete, completed }

enum PriorityFilter {
  all('All'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;
  const PriorityFilter(this.label);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = TaskService();
  late final Stream<List<Task>> _stream = _service.watchTasks();
  TaskFilter _filter = TaskFilter.all;
  PriorityFilter _prio = PriorityFilter.all;
  List<Task> _apply(List<Task> all) {
    return all.where((t) {
      final statusOk = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.incomplete => !t.isCompleted,
        TaskFilter.completed => t.isCompleted,
      };
      final priorityOk = switch (_prio) {
        PriorityFilter.all => true,
        PriorityFilter.high => t.priority == Priority.high,
        PriorityFilter.medium => t.priority == Priority.medium,
        PriorityFilter.low => t.priority == Priority.low,
      };
      return statusOk && priorityOk;
    }).toList(); // Firestore already orders by dueDate (earliest first)
  }

  void _openForm([Task? task]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  void _showProfile() {
    final user = FirebaseAuth.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              user?.displayName ?? 'Account',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              onPressed: () {
                Navigator.pop(context);
                AuthService().logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final first = (user?.displayName ?? '').trim().split(' ').first;
    final name = first.isEmpty ? 'there' : first;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
        onPressed: () => _openForm(),
      ),
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SkylineBackground(),
          ),
          SafeArea(
            child: StreamBuilder<List<Task>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data!;
                final dueToday = all
                    .where((t) => !t.isCompleted && isToday(t.dueDate))
                    .length;
                final tasks = _apply(all);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _welcome(name, dueToday),
                    const SizedBox(height: 20),
                    _controls(),
                    const SizedBox(height: 16),
                    if (tasks.isEmpty)
                      _empty()
                    else
                      for (final t in tasks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _service.delete(t.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.high.withAlpha(60),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.high,
                              ),
                            ),
                            child: TaskCard(
                              task: t,
                              onToggle: () => _service.toggleDone(t),
                              onTap: () => _openForm(t),
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Row(
        children: [
          Icon(
            Icons.check_box_outlined,
            size: 34,
            color: AppColors.primaryLight,
          ),
          SizedBox(width: 12),
          Text(
            'Taskies',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      InkWell(
        onTap: _showProfile,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: const Icon(Icons.person_outline),
        ),
      ),
    ],
  );

  Widget _welcome(String name, int dueToday) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
      gradient: const LinearGradient(
        colors: [AppColors.surface, Color(0xFF1E1236)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back,', style: TextStyle(fontSize: 24)),
        Text(
          '$name!',
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'You have ',
            children: [
              TextSpan(
                text: '$dueToday',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: dueToday == 1 ? ' task due today' : ' tasks due today',
              ),
            ],
          ),
          style: const TextStyle(fontSize: 16, color: AppColors.muted),
        ),
      ],
    ),
  );

  Widget _controls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SegmentedButton<TaskFilter>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.muted,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
        ),
        segments: const [
          ButtonSegment(value: TaskFilter.all, label: Text('All')),
          ButtonSegment(
            value: TaskFilter.incomplete,
            label: Text('Incomplete'),
          ),
          ButtonSegment(value: TaskFilter.completed, label: Text('Completed')),
        ],
        selected: {_filter},
        onSelectionChanged: (s) => setState(() => _filter = s.first),
      ),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton<PriorityFilter>(
          tooltip: 'Filter by priority',
          color: AppColors.surface,
          onSelected: (p) => setState(() => _prio = p),
          itemBuilder: (_) => [
            for (final p in PriorityFilter.values)
              CheckedPopupMenuItem(
                value: p,
                checked: _prio == p,
                child: Text(p.label),
              ),
          ],
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _prio == PriorityFilter.all
                    ? AppColors.border
                    : AppColors.primary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                Text(_prio == PriorityFilter.all ? 'Priority' : _prio.label),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _empty() => Padding(
    padding: const EdgeInsets.only(top: 48),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 56, color: AppColors.muted),
        const SizedBox(height: 12),
        Text(
          _filter == TaskFilter.all && _prio == PriorityFilter.all
              ? 'No tasks yet. Tap "Create Task" to add one.'
              : 'No tasks match these filters.',
          style: const TextStyle(color: AppColors.muted),
        ),
      ],
    ),
  );
}
