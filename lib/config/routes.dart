import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/pages/first_page.dart';
import 'package:katahari/pages/forgot_page.dart';
import 'package:katahari/pages/journal_page.dart';
import 'package:katahari/pages/login_page.dart';
import 'package:katahari/pages/signup_page.dart';
import 'package:katahari/pages/splashscreen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String first = '/first';
  static const String forgot = '/forgot';
  static const String journal = '/journal';
  static const String notes = '/notes';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        path: AppRoutes.first,
        name: 'first',
        builder: (BuildContext context, GoRouterState state) {
          return const FirstPage();
        },
      ),
      GoRoute(
        path: AppRoutes.forgot,
        name: 'forgot',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPage();
        },
      ),
      GoRoute(
        path: AppRoutes.journal,
        name: 'journal',
        builder: (BuildContext context, GoRouterState state) {
          return const journalpage();
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );
}
