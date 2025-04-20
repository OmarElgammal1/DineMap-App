class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? profilePic; // Can be a file path or network URL

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // This is not secure, don't try this at home
      'profile_pic': profilePic,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      profilePic: map['profile_pic'],
    );
  }

  // Optional: Add copyWith method for updates
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profilePic,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}