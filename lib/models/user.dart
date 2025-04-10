class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  // You can add methods for serialization/deserialization if needed
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }
}
