import 'package:appcentricafrica/models/question.dart';
import 'package:appcentricafrica/models/subject.dart';

class Paper {
  final int id;
  final int subjectId;
  final int year;
  final String title;
  final String? description;
  final Subject? subject;
  final List<Question>? questions;

  Paper({
    required this.id,
    required this.subjectId,
    required this.year,
    required this.title,
    this.description,
    this.subject,
    this.questions,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'],
      subjectId: json['subject_id'],
      year: json['year'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'year': year,
      'title': title,
      'description': description,
      'subject': subject != null ? {
        'id': subject!.id,
        'name': subject!.name,
        'code': subject!.code,
      } : null,
      'questions': questions?.map((q) => q.toJson()).toList(),
    };
  }
}