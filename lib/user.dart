class User {
  final int? id;
  final String name;
  final String gender;
  final String studentId;
  final String email;
  final int level;
  final String password;
  final String? profilePic; // Can be a file path or network URL

  User({
    this.id,
    required this.name,
    required this.gender,
    required this.studentId,
    required this.email,
    required this.level,
    required this.password,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'student_id': studentId,
      'email': email,
      'level': level,
      'password': password, // This is not secure, don't try this at home
      'profile_pic': profilePic,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      studentId: map['student_id'],
      email: map['email'],
      level: map['level'],
      password: map['password'],
      profilePic: map['profile_pic'],
    );
  }

  // Optional: Add copyWith method for updates
  User copyWith({
    int? id,
    String? name,
    String? gender,
    String? studentId,
    String? email,
    int? level,
    String? password,
    String? profilePic,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      level: level ?? this.level,
      password: password ?? this.password,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}