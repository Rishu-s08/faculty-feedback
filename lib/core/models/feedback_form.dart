import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FeedbackForm {
  final String id;
  final String subject;
  final String facultyName;
  final int year;
  final int semester;
  final String branch;
  final int totalResponses;
  final Map<String, double> ratings;
  final List<String> questions;
  final DateTime createdAt;
  FeedbackForm({
    required this.id,
    required this.subject,
    required this.facultyName,
    required this.year,
    required this.semester,
    required this.branch,
    required this.totalResponses,
    required this.ratings,
    required this.questions,
    required this.createdAt,
  });

  FeedbackForm copyWith({
    String? id,
    String? subject,
    String? facultyName,
    int? year,
    String? branch,
    int? semester,
    int? totalResponses,
    Map<String, double>? ratings,
    List<String>? questions,
    DateTime? createdAt,
  }) {
    return FeedbackForm(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      facultyName: facultyName ?? this.facultyName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      branch: branch ?? this.branch,
      totalResponses: totalResponses ?? this.totalResponses,
      ratings: ratings ?? this.ratings,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'subject': subject,
      'facultyName': facultyName,
      'year': year,
      'semester': semester,
      'totalResponses': totalResponses,
      'branch': branch,
      'ratings': ratings,
      'questions': questions,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FeedbackForm.fromMap(Map<String, dynamic> map) {
    return FeedbackForm(
      id: map['id'] as String,
      subject: map['subject'] as String,
      facultyName: map['facultyName'] as String,
      year: map['year'] as int,
      semester: map['semester'] as int,
      branch: map['branch'] as String,
      totalResponses: map['totalResponses'] as int,
      ratings: Map<String, double>.from(map['ratings']),
      questions: List<String>.from(map['questions']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  @override
  String toString() {
    return 'FeedbackForm(id: $id, subject: $subject, facultyName: $facultyName, year: $year, semester: $semester, totalResponses: $totalResponses, ratings: $ratings, questions: $questions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant FeedbackForm other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.subject == subject &&
        other.facultyName == facultyName &&
        other.year == year &&
        other.semester == semester &&
        other.totalResponses == totalResponses &&
        mapEquals(other.ratings, ratings) &&
        listEquals(other.questions, questions) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        subject.hashCode ^
        facultyName.hashCode ^
        year.hashCode ^
        semester.hashCode ^
        totalResponses.hashCode ^
        ratings.hashCode ^
        questions.hashCode ^
        createdAt.hashCode;
  }
}
