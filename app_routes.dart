import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/quiz_list_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/splash_screen.dart';
import '../models/quiz_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String quizList = '/quiz-list';
  static const String quiz = '/quiz';
  static const String result = '/result';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case login:
        return _slideRoute(const LoginScreen(), settings);
      case signup:
        return _slideRoute(const SignupScreen(), settings);
      case home:
        return _fadeRoute(const HomeScreen(), settings);
      case profile:
        return _slideRoute(const ProfileScreen(), settings);
      case quizList:
        return _slideRoute(const QuizListScreen(), settings);
      case quiz:
        final quizModel = settings.arguments as QuizModel;
        return _slideRoute(QuizScreen(quiz: quizModel), settings);
      case result:
        final args = settings.arguments as ResultArgs;
        return _slideRoute(ResultScreen(args: args), settings);
      default:
        return _fadeRoute(const LoginScreen(), settings);
    }
  }

  static PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

class ResultArgs {
  final String quizTitle;
  final int score;
  final int total;
  final String participantName;

  ResultArgs({
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.participantName,
  });
}
