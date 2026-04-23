import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final int order;
  final int questionCount;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.order,
    required this.questionCount,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '📚',
      color: data['color'] ?? '0xFF6C63FF',
      order: data['order'] ?? 0,
      questionCount: data['questionCount'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
        'order': order,
        'questionCount': questionCount,
      };
}
