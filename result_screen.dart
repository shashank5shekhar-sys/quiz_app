import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatefulWidget {
  final ResultArgs args;

  const ResultScreen({super.key, required this.args});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scoreController;
  late AnimationController _confettiController;

  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _scoreAnim;

  late bool _passed;
  late double _percentage;

  @override
  void initState() {
    super.initState();

    _percentage = widget.args.total > 0
        ? (widget.args.score / widget.args.total * 100)
        : 0;
    _passed = _percentage >= AppConstants.passingPercentage;

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );
    _scoreAnim = Tween<double>(begin: 0, end: _percentage / 100).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _mainController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _scoreController.forward();
      if (_passed) _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scoreController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: _buildResultBadge(),
                    ),
                    const SizedBox(height: 32),
                    _buildScoreCircle(),
                    const SizedBox(height: 32),
                    _buildStatsCard(),
                    const SizedBox(height: 32),
                    _buildMessage(),
                    const SizedBox(height: 36),
                    _buildActions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                (_passed ? AppColors.success : AppColors.error).withAlpha(30),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withAlpha(25),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBadge() {
    final color = _passed ? AppColors.success : AppColors.error;
    final emoji = _passed ? '🏆' : '📚';
    final label = _passed ? 'PASS' : 'FAIL';

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(25),
            border: Border.all(color: color, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(50),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 44)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
        ),
        if (_passed) ...[
          const SizedBox(height: 12),
          const Text(
            '🎉 Congratulations! 🎉',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreCircle() {
    final color = _passed ? AppColors.success : AppColors.error;

    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (_, __) {
        final displayPct = (_scoreAnim.value * 100).toInt();
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _scoreAnim.value,
                  strokeWidth: 10,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$displayPct%',
                    style: TextStyle(
                      color: color,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Score',
                    style: TextStyle(
                      color: color.withAlpha(180),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            widget.args.quizTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('${widget.args.score}', 'Correct', AppColors.success),
              _statItem(
                '${widget.args.total - widget.args.score}',
                'Incorrect',
                AppColors.error,
              ),
              _statItem('${widget.args.total}', 'Total', AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                widget.args.participantName,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    final message = _passed
        ? 'Outstanding! You scored ${_percentage.toInt()}% and passed this quiz. Keep challenging yourself!'
        : 'You scored ${_percentage.toInt()}%. You need 90% to pass. Review the topic and try again — you\'ve got this!';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (_passed ? AppColors.success : AppColors.warning).withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (_passed ? AppColors.success : AppColors.warning).withAlpha(60),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _passed ? '💡' : '📖',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomButton(
          label: 'Try Another Quiz',
          icon: Icons.quiz_outlined,
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.quizList,
              (r) => r.settings.name == AppRoutes.home,
            );
          },
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: 'Back to Home',
          outlined: true,
          icon: Icons.home_outlined,
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (r) => false,
            );
          },
        ),
      ],
    );
  }
}
