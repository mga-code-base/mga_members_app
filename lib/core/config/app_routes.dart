import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/branches/branches_screen.dart';
import '../../screens/chat/trainer_bot_screen.dart';
import '../../screens/common/home_screen.dart';
import '../../screens/common/splash_screen.dart';
import '../../screens/grievances/grievances_screen.dart';
import '../../screens/posture/posture_screen.dart';
import '../../screens/trainer/trainer_screen.dart';
import '../../screens/workout/log_workout_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String logWorkout = '/log-workout';
  static const String myTrainer = '/my-trainer';
  static const String branches = '/branches';
  static const String trainerBot = '/trainer-bot';
  static const String posture = '/posture';
  static const String grievances = '/grievances';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        home: (_) => const HomeScreen(),
        logWorkout: (_) => const LogWorkoutWizard(),
        myTrainer: (_) => const MyTrainerScreen(),
        branches: (_) => const BranchesScreen(),
        trainerBot: (_) => const TrainerBotScreen(),
        posture: (_) => const PostureScreen(),
        grievances: (_) => const GrievanceScreen(),
      };
}
