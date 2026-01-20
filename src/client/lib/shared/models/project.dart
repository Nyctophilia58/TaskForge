class Project {
  final int id;
  final int buyerId;
  final String title;
  final String description;

  Project({required this.id, required this.buyerId, required this.title, required this.description});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      buyerId: json['buyer_id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}