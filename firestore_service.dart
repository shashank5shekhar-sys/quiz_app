import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Fetch All Quizzes ────────────────────────────────────────────────────
  static Future<List<QuizModel>> fetchQuizzes() async {
    try {
      final snapshot = await _db
          .collection('quizzes')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Fetch Questions for a Quiz ───────────────────────────────────────────
  static Future<List<QuestionModel>> fetchQuestions(String quizId) async {
    try {
      final snapshot = await _db
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ─── Save Quiz Result ──────────────────────────────────────────────────────
  static Future<void> saveQuizResult({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required String participantName,
    required String participantPhone,
  }) async {
    try {
      final uid = _auth.currentUser?.uid ?? 'anonymous';
      final percentage = (score / totalQuestions * 100).round();

      await _db.collection('quiz_results').add({
        'uid': uid,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'passed': percentage >= 90,
        'participantName': participantName,
        'participantPhone': participantPhone,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail — don't block UI
    }
  }

  // ─── Seed Sample Quizzes (run once from admin) ────────────────────────────
  /// Call this once to populate Firestore with 5 sample quizzes.
  /// You can run it from a debug button or Firebase console seeder.
  static Future<void> seedSampleData() async {
    final quizzes = [
      {
        'id': 'quiz_1',
        'title': 'General Knowledge',
        'description': 'Test your everyday knowledge!',
        'icon': '🌍',
        'color': '0xFF6C63FF',
        'order': 1,
        'questionCount': 5,
        'questions': [
          {
            'order': 1,
            'question': 'What is the capital of France?',
            'options': ['Berlin', 'Madrid', 'Paris', 'Rome'],
            'correctIndex': 2,
          },
          {
            'order': 2,
            'question': 'How many continents are there on Earth?',
            'options': ['5', '6', '7', '8'],
            'correctIndex': 2,
          },
          {
            'order': 3,
            'question': 'Which is the largest ocean?',
            'options': ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
            'correctIndex': 3,
          },
          {
            'order': 4,
            'question': 'What is H2O commonly known as?',
            'options': ['Salt', 'Water', 'Oxygen', 'Hydrogen'],
            'correctIndex': 1,
          },
          {
            'order': 5,
            'question': 'Who wrote "Romeo and Juliet"?',
            'options': ['Dickens', 'Shakespeare', 'Tolstoy', 'Homer'],
            'correctIndex': 1,
          },
        ],
      },
      {
        'id': 'quiz_2',
        'title': 'Science & Technology',
        'description': 'How well do you know science?',
        'icon': '🔬',
        'color': '0xFF00D9C8',
        'order': 2,
        'questionCount': 5,
        'questions': [
          {
            'order': 1,
            'question': 'What planet is known as the Red Planet?',
            'options': ['Earth', 'Venus', 'Mars', 'Jupiter'],
            'correctIndex': 2,
          },
          {
            'order': 2,
            'question': 'What is the speed of light (approx)?',
            'options': ['300,000 km/s', '150,000 km/s', '500,000 km/s', '100,000 km/s'],
            'correctIndex': 0,
          },
          {
            'order': 3,
            'question': 'DNA stands for?',
            'options': [
              'Digital Network Access',
              'Deoxyribonucleic Acid',
              'Dynamic Neuron Array',
              'Data Network Architecture'
            ],
            'correctIndex': 1,
          },
          {
            'order': 4,
            'question': 'Which element has atomic number 1?',
            'options': ['Helium', 'Oxygen', 'Hydrogen', 'Carbon'],
            'correctIndex': 2,
          },
          {
            'order': 5,
            'question': 'Who invented the telephone?',
            'options': ['Edison', 'Tesla', 'Bell', 'Marconi'],
            'correctIndex': 2,
          },
        ],
      },
      {
        'id': 'quiz_3',
        'title': 'Mathematics',
        'description': 'Put your math skills to the test!',
        'icon': '📐',
        'color': '0xFFFF6B6B',
        'order': 3,
        'questionCount': 5,
        'questions': [
          {
            'order': 1,
            'question': 'What is 15 × 15?',
            'options': ['200', '215', '225', '230'],
            'correctIndex': 2,
          },
          {
            'order': 2,
            'question': 'What is the square root of 144?',
            'options': ['10', '11', '12', '13'],
            'correctIndex': 2,
          },
          {
            'order': 3,
            'question': 'What is π (pi) approximately equal to?',
            'options': ['3.14', '3.41', '3.12', '3.16'],
            'correctIndex': 0,
          },
          {
            'order': 4,
            'question': 'If x + 5 = 12, what is x?',
            'options': ['5', '6', '7', '8'],
            'correctIndex': 2,
          },
          {
            'order': 5,
            'question': 'How many degrees in a right angle?',
            'options': ['45°', '60°', '90°', '180°'],
            'correctIndex': 2,
          },
        ],
      },
      {
        'id': 'quiz_4',
        'title': 'History',
        'description': 'How well do you know the past?',
        'icon': '📜',
        'color': '0xFFFFB347',
        'order': 4,
        'questionCount': 5,
        'questions': [
          {
            'order': 1,
            'question': 'In which year did World War II end?',
            'options': ['1943', '1944', '1945', '1946'],
            'correctIndex': 2,
          },
          {
            'order': 2,
            'question': 'Who was the first President of the USA?',
            'options': ['Lincoln', 'Jefferson', 'Washington', 'Adams'],
            'correctIndex': 2,
          },
          {
            'order': 3,
            'question': 'The Great Wall of China was built to protect against?',
            'options': ['Floods', 'Mongol invasions', 'Pirates', 'Earthquakes'],
            'correctIndex': 1,
          },
          {
            'order': 4,
            'question': 'Which empire was ruled by Julius Caesar?',
            'options': ['Greek', 'Ottoman', 'Roman', 'Persian'],
            'correctIndex': 2,
          },
          {
            'order': 5,
            'question': 'India gained independence in which year?',
            'options': ['1945', '1947', '1948', '1950'],
            'correctIndex': 1,
          },
        ],
      },
      {
        'id': 'quiz_5',
        'title': 'Computer Science',
        'description': 'Are you a tech wizard?',
        'icon': '💻',
        'color': '0xFF7ED321',
        'order': 5,
        'questionCount': 5,
        'questions': [
          {
            'order': 1,
            'question': 'What does CPU stand for?',
            'options': [
              'Central Processing Unit',
              'Core Processing Utility',
              'Central Program Unit',
              'Computer Processing Unit'
            ],
            'correctIndex': 0,
          },
          {
            'order': 2,
            'question': 'Which language is used for web styling?',
            'options': ['HTML', 'Python', 'CSS', 'Java'],
            'correctIndex': 2,
          },
          {
            'order': 3,
            'question': 'What does RAM stand for?',
            'options': [
              'Random Access Memory',
              'Read Access Memory',
              'Remote Application Module',
              'Runtime Access Mode'
            ],
            'correctIndex': 0,
          },
          {
            'order': 4,
            'question': 'What is the binary representation of the number 5?',
            'options': ['100', '101', '110', '111'],
            'correctIndex': 1,
          },
          {
            'order': 5,
            'question': 'Which company created Flutter?',
            'options': ['Apple', 'Microsoft', 'Google', 'Facebook'],
            'correctIndex': 2,
          },
        ],
      },
    ];

    for (final quiz in quizzes) {
      final questions = quiz['questions'] as List;
      final quizData = Map<String, dynamic>.from(quiz)..remove('questions');

      final docRef = _db.collection('quizzes').doc(quiz['id'] as String);
      await docRef.set(quizData);

      for (final q in questions) {
        await docRef.collection('questions').add(Map<String, dynamic>.from(q as Map));
      }
    }
  }
}
