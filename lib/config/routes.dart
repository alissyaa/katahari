import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/pages/journal/add_journal_page.dart';
import 'package:katahari/pages/registrasi/first_page.dart';
import 'package:katahari/pages/forgotpass/forgot_page.dart';
import 'package:katahari/pages/journal/journal_detail_page.dart';
import 'package:katahari/pages/journal/journal_page.dart';
import 'package:katahari/pages/registrasi/login_page.dart';
import 'package:katahari/pages/registrasi/signup_page.dart';
import 'package:katahari/pages/registrasi/splashscreen.dart';
import 'package:katahari/pages/todo/create_todo_page.dart';
import 'package:katahari/pages/todo/todo_page.dart';
import '../components/bottom_navigation_shell.dart';
import '../pages/edit_profile_page.dart';
import '../pages/journal_mood_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/todo/edit_todo_page.dart';
import 'package:katahari/models/todo_model.dart';


// Definisikan path sebagai konstanta agar mudah dikelola
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String first = '/first';
  static const String forgot = '/forgot';
  static const String addJournal = '/add_journal';
  static const String journal = '/journal';
  static const String todo = '/todo';
  static const String profile = '/profile';
  static const String journalDetail = '/journal_detail';
  static const String editJournal = '/edit_journal';
  static const String addTodos = '/addTodos';
  static const editTodo = '/edit_todo';
  static const settings = '/settings/settings_page';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      // Rute-rute ini tidak memiliki Navbar
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.first,
        builder: (context, state) => const FirstPage(),
      ),
      GoRoute(
        path: AppRoutes.forgot,
        builder: (context, state) => const ForgotPage(),
      ),
      GoRoute(
        path: '${AppRoutes.journalDetail}/:journalId',
        builder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          return JournalDetailPage(journalId: journalId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.editJournal}/:journalId',
        builder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          return AddJournalPage(journalId: journalId);
        },
      ),
      GoRoute(
        path: AppRoutes.addJournal,
        builder: (context, state) => const AddJournalPage(),
      ),
      GoRoute(
        path: AppRoutes.addTodos,
        builder: (context, state) => const CreateTodoPage(),
      ),
      GoRoute(
        path: AppRoutes.editTodo,
        builder: (context, state) {
          final todo = state.extra as Todo;
          return EditTodoPage(todo: todo);
        },
      ),
      GoRoute(
        path: '/profile/mood_journal_list/:mood',
        builder: (context, state) {
          final mood = state.pathParameters['mood']!;
          return JournalMoodPage(mood: mood);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return EditProfilePage(
            currentName: extra?['name'] ?? '',
            currentBirthday: extra?['birthday'] ?? '',
            currentMbti: extra?['mbti'] ?? '',
            currentCardColor: extra?['cardColor'] ?? 0xFFFFFFFF,
            currentHeaderColor: extra?['headerColor'] ?? 0xFF000000,
            currentImageUrl: extra?['imageUrl'],
          );
        },
      ),




      // Rute-rute ini akan memiliki Navbar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.todo,
                builder: (context, state) => const TodoPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const JournalPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );
}
