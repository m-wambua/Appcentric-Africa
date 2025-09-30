import 'package:appcentricafrica/models/answer.dart';

class Question {
  final int id;
  final int paperId;
  final String questionText;
  final int marks;
  final int order;
  final List<Answer>? answers;

  Question({
    required this.id,
    required this.paperId,
    required this.questionText,
    required this.marks,
    required this.order,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      paperId: json['paper_id'],
      questionText: json['question_text'],
      marks: json['marks'],
      order: json['order'],
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => Answer.fromJson(a)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paper_id': paperId,
      'question_text': questionText,
      'marks': marks,
      'order': order,
      'answers': answers?.map((a) => a.toJson()).toList(),
    };
  }
}