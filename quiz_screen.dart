import 'package:flutter/material.dart';
import '../firebase/firestore_service.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../utils/theme.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // Quiz state
  List<QuestionModel> _questions = [];
  bool _loading = true;
  bool _started = false;

  // Pre-quiz form
  final _preFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Quiz progress
  int _currentIndex = 0;
  int? _selectedOption;
  final Map<int, int> _answers = {};
  bool _answered = false;

  late AnimationController _progressController;
  late AnimationController _questionAnimController;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _questionAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _questionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _questionAnimController, curve: Curves.easeOut),
    );
    _questionSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionAnimController, curve: Curves.easeOut));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await FirestoreService.fetchQuestions(widget.quiz.id);
    if (mounted) {
      setState(() {
        _questions = questions;
        _loading = false;
      });
    }
  }

  void _startQuiz() {
    if (!_preFormKey.currentState!.validate()) return;
    setState(() => _started = true);
    _questionAnimController.forward(from: 0);
    _updateProgress();
  }

  void _updateProgress() {
    final progress = _questions.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _questions.length;
    _progressController.animateTo(progress);
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      _answers[_currentIndex] = index;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
      _questionAnimController.forward(from: 0);
      _updateProgress();
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) {
        score++;
      }
    }

    // Save result to Firestore
    await FirestoreService.saveQuizResult(
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      score: score,
      totalQuestions: _questions.length,
      participantName: _nameController.text,
      participantPhone: _phoneController.text,
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.result,
        arguments: ResultArgs(
          quizTitle: widget.quiz.title,
          score: score,
          total: _questions.length,
          participantName: _nameController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionAnimController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const LoadingWidget(message: 'Loading questions...')
          : !_started
              ? _buildPreForm()
              : _buildQuiz(),
    );
  }

  // ─── Pre-Quiz Form ──────────────────────────────────────────────────────────
  Widget _buildPreForm() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.primary.withAlpha(30), Colors.transparent]),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // Back button row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quiz Info Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF5A4FE0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(widget.quiz.icon, style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.quiz.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${widget.quiz.questionCount} questions • Pass: 90%',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Before you begin',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter your details to get started.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: _preFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Your Name',
                                hintText: 'Enter your full name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Name is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: '+91 98765 43210',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Phone is required';
                                if (v.trim().length < 10) return 'Enter a valid phone number';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        label: 'Start Quiz',
                        icon: Icons.play_arrow_rounded,
                        onPressed: _startQuiz,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Quiz Screen ────────────────────────────────────────────────────────────
  Widget _buildQuiz() {
    if (_questions.isEmpty) {
      return const Center(
        child: Text('No questions found.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final q = _questions[_currentIndex];

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showExitDialog(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                    Text(
                      widget.quiz.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Question
          Expanded(
            child: FadeTransition(
              opacity: _questionFade,
              child: SlideTransition(
                position: _questionSlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Q number badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Question ${_currentIndex + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        q.question,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Options
                      ...List.generate(q.options.length, (i) => _buildOption(i, q.options[i], q.correctIndex)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom bar
          if (_answered)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: CustomButton(
                label: _currentIndex < _questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                icon: _currentIndex < _questions.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.check_circle_rounded,
                onPressed: _nextQuestion,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text, int correctIndex) {
    Color bgColor = AppColors.surfaceCard;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.textPrimary;
    Widget? trailingIcon;

    if (_answered) {
      if (index == correctIndex) {
        bgColor = AppColors.success.withAlpha(25);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        trailingIcon = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
      } else if (index == _selectedOption && index != correctIndex) {
        bgColor = AppColors.error.withAlpha(20);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        trailingIcon = const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
      }
    } else if (_selectedOption == index) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withAlpha(20);
    }

    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: borderColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letters[index],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Quiz?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress will be lost if you exit now.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
