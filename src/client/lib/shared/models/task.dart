class Task {
  final int id;
  final int projectId;
  final int? developerId;
  final String title;
  final String description;
  final double hourlyRate;
  final double? hoursSpent;
  final String status; // todo, in_progress, submitted, paid
  final String? zipPath;

  Task({
    required this.id,
    required this.projectId,
    this.developerId,
    required this.title,
    required this.description,
    required this.hourlyRate,
    this.hoursSpent,
    required this.status,
    this.zipPath,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['project_id'],
      developerId: json['developer_id'],
      title: json['title'],
      description: json['description'],
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      hoursSpent: json['hours_spent'] != null ? (json['hours_spent'] as num).toDouble() : null,
      status: json['status'],
      zipPath: json['zip_path'],
    );
  }

  double get amountDue => hoursSpent != null ? hourlyRate * hoursSpent! : 0.0;
}