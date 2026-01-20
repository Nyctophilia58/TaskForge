import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/admin_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(adminStatsProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Statistic Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard('Total Projects', stats.totalProjects, Icons.folder, Colors.blue),
                    _buildStatCard('Total Tasks', stats.totalTasks, Icons.task, Colors.orange),
                    _buildStatCard('Completed Tasks', stats.completedTasks, Icons.check_circle, Colors.green),
                    _buildStatCard('Pending Payments', stats.pendingPayments, Icons.payment, Colors.red),
                    _buildStatCard('Total Revenue', '\$${stats.totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.purple),
                    _buildStatCard('Hours Logged', stats.totalHoursLogged.toStringAsFixed(1), Icons.timer, Colors.teal),
                    _buildStatCard('Total Buyers', stats.totalBuyers, Icons.person, Colors.indigo),
                    _buildStatCard('Total Developers', stats.totalDevelopers, Icons.code, Colors.cyan),
                  ],
                ),
                const SizedBox(height: 30),

                // Task Status Pie Chart
                Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Task Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                // Todo / In Progress
                                PieChartSectionData(
                                  value: (stats.totalTasks - stats.completedTasks - stats.pendingPayments).toDouble(),
                                  title: 'Todo/In Progress',
                                  color: Colors.grey,
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),

                                // Submitted (pending payment)
                                PieChartSectionData(
                                  value: stats.pendingPayments.toDouble(),
                                  title: 'Submitted',
                                  color: Colors.amber,
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),

                                // Paid (completed & paid)
                                PieChartSectionData(
                                  value: (stats.completedTasks - stats.pendingPayments).toDouble(),
                                  title: 'Paid',
                                  color: Colors.green,
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              pieTouchData: PieTouchData(enabled: true),
                            ),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(adminStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}