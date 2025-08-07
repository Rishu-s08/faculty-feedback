class UserModel {
  final String uid;
  final String email;
  final String name;
  final String branch;
  final int? semester;
  final String role; // 'student' or 'admin'
  final List<String> submittedFormIds; // ✅ NEW FIELD

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.branch,
    this.semester,
    required this.role,
    this.submittedFormIds = const [], // ✅ default empty
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? branch,
    int? semester,
    String? role,
    List<String>? submittedFormIds, // ✅
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      submittedFormIds: submittedFormIds ?? this.submittedFormIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'name': name,
      'branch': branch,
      'semester': semester,
      'role': role,
      'submittedFormIds': submittedFormIds, // ✅ serialize
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      branch: map['branch'] as String,
      semester: map['semester'] != null ? map['semester'] as int : null,
      role: map['role'] as String,
      submittedFormIds:
          map['submittedFormIds'] != null
              ? List<String>.from(map['submittedFormIds'])
              : [],
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, branch: $branch, semester: $semester, role: $role, submittedFormIds: $submittedFormIds)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.branch == branch &&
        other.semester == semester &&
        other.role == role &&
        _listEquals(other.submittedFormIds, submittedFormIds);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        branch.hashCode ^
        semester.hashCode ^
        role.hashCode ^
        submittedFormIds.hashCode;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
