import 'package:client/features/developer/presentation/submit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/devloper_providers.dart';

class DeveloperDashboard extends ConsumerWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks'), backgroundColor: Colors.green),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myTasksProvider.future),
        child: tasksAsync.when(
          data: (tasks) => tasks.isEmpty
              ? const Center(child: Text('No tasks assigned yet'))
              : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text('Project ID: ${task.projectId} • Status: ${task.status}'),
                  trailing: task.status == 'todo'
                      ? ElevatedButton(
                    onPressed: () async {
                      await ref.read(developerServiceProvider).startTask(task.id);
                      ref.refresh(myTasksProvider);
                    },
                    child: const Text('Start'),
                  )
                      : task.status == 'in_progress'
                      ? ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SubmitTaskScreen(task: task)),
                    ),
                    child: const Text('Submit'),
                  )
                      : Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      color:task.status == 'submitted' ? Colors.amber : Colors.green,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}