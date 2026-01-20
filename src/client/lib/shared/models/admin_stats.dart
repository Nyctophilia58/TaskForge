class AdminStats {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int totalPaymentsCompleted;
  final int pendingPayments;
  final double totalHoursLogged;
  final double totalRevenue;
  final int totalBuyers;
  final int totalDevelopers;

  AdminStats({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPaymentsCompleted,
    required this.pendingPayments,
    required this.totalHoursLogged,
    required this.totalRevenue,
    required this.totalBuyers,
    required this.totalDevelopers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalProjects: json['total_projects'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      totalPaymentsCompleted: json['total_payments_completed'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      totalHoursLogged: (json['total_hours_logged'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalBuyers: json['total_buyers'] ?? 0,
      totalDevelopers: json['total_developers'] ?? 0,
    );
  }
}