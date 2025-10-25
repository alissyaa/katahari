import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:katahari/pages/splashscreen.dart';
import 'package:katahari/wrapper.dart';
import 'package:katahari/pages/login_page.dart';
import 'package:katahari/pages/signup_page.dart';
import 'package:katahari/pages/journal_page.dart';
import 'package:katahari/pages/first_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Katahari',

      initialRoute: '/splash',

      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/wrapper', page: () => const Wrapper()),
        GetPage(name: '/first', page: () => const FirstPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/journal', page: () => const journalpage()),
      ],
    );
  }
}