class SimpleUser {
  final int id;
  final String email;

  SimpleUser({required this.id, required this.email});

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'],
      email: json['email'],
    );
  }

  @override
  String toString() => email; // for dropdown display
}