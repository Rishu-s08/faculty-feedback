class UserModel {
  final String uid;
  final String email;
  final String name;
  final int? sem;
  final String role; // 'student' or 'admin'
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.sem,
    required this.role,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? sem,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      sem: sem ?? this.sem,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'name': name,
      'sem': sem,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      sem: map['sem'] != null ? map['sem'] as int : null,
      role: map['role'] as String,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, sem: $sem, role: $role)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.sem == sem &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        sem.hashCode ^
        role.hashCode;
  }
}
