import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/utils/task_actions.dart';
import '../../../shared/models/task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'submitted':
        return Colors.amber;
      case 'paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(task.status);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Task Details'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.8),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card with Glassmorphism
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.15),
                    // backdropFilter: const BlurFilter(), // if you have blur package
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              task.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: statusColor.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Details Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem('Hourly Rate', '\$${task.hourlyRate.toStringAsFixed(2)}', Icons.attach_money, theme),
                      const Divider(height: 30),
                      if (task.developerId != null)
                        _buildDetailItem('Assigned Developer', 'ID: ${task.developerId}', Icons.person, theme),
                      if (task.hoursSpent != null) ...[
                        const Divider(height: 30),
                        _buildDetailItem('Hours Spent', task.hoursSpent!.toStringAsFixed(1), Icons.timer, theme),
                        const Divider(height: 30),
                        _buildDetailItem(
                          'Amount Due',
                          '\$${task.amountDue.toStringAsFixed(2)}',
                          Icons.payment,
                          theme,
                          valueColor: Colors.amber.shade700,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                if (task.status == 'submitted')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => TaskActions.payForTask(context: context, ref: ref, task: task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 24),
                          SizedBox(width: 12),
                          Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else if (task.status == 'paid')
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => TaskActions.downloadZip(context: context, ref: ref, task: task),
                      icon: const Icon(Icons.download_rounded, size: 28),
                      label: const Text('Download ZIP Solution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, dynamic theme, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}