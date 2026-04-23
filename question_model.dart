import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int order;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.order,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctIndex: data['correctIndex'] ?? 0,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'order': order,
      };
}
