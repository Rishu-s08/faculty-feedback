import 'package:flutter/foundation.dart';

class ResponseForm {
  final String id;
  final String formID;
  final String faculty;
  final String subject;
  final int sem;
  final int? batchYear;
  final String branch;
  final String studentName;
  final String studentEmail;
  final Map<String, int> responses;
  final String? comment;
  final String? academicYear;    // e.g. "2026-2027"
  final String? term;            // "Odd" or "Even"
  final String? feedbackCycle;   // e.g. "2026-2027_Odd"
  ResponseForm({
    required this.id,
    required this.formID,
    required this.faculty,
    required this.subject,
    required this.sem,
    this.batchYear,
    required this.branch,
    required this.studentName,
    required this.studentEmail,
    required this.responses,
    this.comment,
    this.academicYear,
    this.term,
    this.feedbackCycle,
  });

  ResponseForm copyWith({
    String? id,
    String? formID,
    String? faculty,
    String? subject,
    int? sem,
    int? batchYear,
    String? branch,
    String? studentName,
    String? studentEmail,
    Map<String, int>? responses,
    String? comment,
    String? academicYear,
    String? term,
    String? feedbackCycle,
  }) {
    return ResponseForm(
      id: id ?? this.id,
      formID: formID ?? this.formID,
      faculty: faculty ?? this.faculty,
      subject: subject ?? this.subject,
      sem: sem ?? this.sem,
      batchYear: batchYear ?? this.batchYear,
      branch: branch ?? this.branch,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      responses: responses ?? this.responses,
      comment: comment ?? this.comment,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      feedbackCycle: feedbackCycle ?? this.feedbackCycle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'formID': formID,
      'faculty': faculty,
      'subject': subject,
      'sem': sem,
      'batchYear': batchYear,
      'branch': branch,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'responses': responses,
      'comment': comment,
      'academicYear': academicYear,
      'term': term,
      'feedbackCycle': feedbackCycle,
    };
  }

  factory ResponseForm.fromMap(Map<String, dynamic> map) {
    return ResponseForm(
      id: map['id'] as String,
      formID: map['formID'] as String,
      faculty: map['faculty'] as String,
      subject: map['subject'] as String,
      sem: map['sem'] as int,
      batchYear: map['batchYear'] != null ? (map['batchYear'] as num).toInt() : null,
      branch: map['branch'] as String,
      studentName: map['studentName'] as String,
      studentEmail: map['studentEmail'] as String,
      responses: Map<String, int>.from((map['responses'])),
      comment: map['comment'] != null ? map['comment'] as String : null,
      academicYear: map['academicYear'] != null ? map['academicYear'] as String : null,
      term: map['term'] != null ? map['term'] as String : null,
      feedbackCycle: map['feedbackCycle'] != null ? map['feedbackCycle'] as String : null,
    );
  }

  @override
  String toString() {
    return 'ResponseForm(id: $id, formID: $formID, faculty: $faculty, subject: $subject, sem: $sem, batchYear: $batchYear, branch: $branch, studentName: $studentName, studentEmail: $studentEmail, responses: $responses, comment: $comment, academicYear: $academicYear, term: $term, feedbackCycle: $feedbackCycle)';
  }

  @override
  bool operator ==(covariant ResponseForm other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.formID == formID &&
        other.faculty == faculty &&
        other.subject == subject &&
        other.sem == sem &&
        other.batchYear == batchYear &&
        other.branch == branch &&
        other.studentName == studentName &&
        other.studentEmail == studentEmail &&
        mapEquals(other.responses, responses) &&
        other.comment == comment &&
        other.academicYear == academicYear &&
        other.term == term &&
        other.feedbackCycle == feedbackCycle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        formID.hashCode ^
        faculty.hashCode ^
        subject.hashCode ^
        sem.hashCode ^
        batchYear.hashCode ^
        branch.hashCode ^
        studentName.hashCode ^
        studentEmail.hashCode ^
        responses.hashCode ^
        comment.hashCode ^
        academicYear.hashCode ^
        term.hashCode ^
        feedbackCycle.hashCode;
  }
}
