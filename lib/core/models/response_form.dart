import 'package:flutter/foundation.dart';

class ResponseForm {
  final String id;
  final String formID;
  final String faculty;
  final String subject;
  final int sem;
  final String studentName;
  final String studentEmail;
  final Map<String, int> responses;
  final String? comment;
  ResponseForm({
    required this.id,
    required this.formID,
    required this.faculty,
    required this.subject,
    required this.sem,
    required this.studentName,
    required this.studentEmail,
    required this.responses,
    this.comment,
  });

  ResponseForm copyWith({
    String? id,
    String? formID,
    String? faculty,
    String? subject,
    int? sem,
    String? studentName,
    String? studentEmail,
    Map<String, int>? responses,
    String? comment,
  }) {
    return ResponseForm(
      id: id ?? this.id,
      formID: formID ?? this.formID,
      faculty: faculty ?? this.faculty,
      subject: subject ?? this.subject,
      sem: sem ?? this.sem,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      responses: responses ?? this.responses,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'formID': formID,
      'faculty': faculty,
      'subject': subject,
      'sem': sem,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'responses': responses,
      'comment': comment,
    };
  }

  factory ResponseForm.fromMap(Map<String, dynamic> map) {
    return ResponseForm(
      id: map['id'] as String,
      formID: map['formID'] as String,
      faculty: map['faculty'] as String,
      subject: map['subject'] as String,
      sem: map['sem'] as int,
      studentName: map['studentName'] as String,
      studentEmail: map['studentEmail'] as String,
      responses: Map<String, int>.from((map['responses'])),
      comment: map['comment'] != null ? map['comment'] as String : null,
    );
  }

  @override
  String toString() {
    return 'ResponseForm(id: $id, formID: $formID, faculty: $faculty, subject: $subject, sem: $sem, studentName: $studentName, studentEmail: $studentEmail, responses: $responses, comment: $comment)';
  }

  @override
  bool operator ==(covariant ResponseForm other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.formID == formID &&
        other.faculty == faculty &&
        other.subject == subject &&
        other.sem == sem &&
        other.studentName == studentName &&
        other.studentEmail == studentEmail &&
        mapEquals(other.responses, responses) &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        formID.hashCode ^
        faculty.hashCode ^
        subject.hashCode ^
        sem.hashCode ^
        studentName.hashCode ^
        studentEmail.hashCode ^
        responses.hashCode ^
        comment.hashCode;
  }
}
