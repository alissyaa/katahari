import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katahari/config/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview/device_preview.dart'; // import Device Preview
import 'firebase_options.dart';

final _appRouter = createRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://kbyjftdcdcqhwvictpjd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtieWpmdGRjZGNxaHd2aWN0cGpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4MzM4MjQsImV4cCI6MjA4MDQwOTgyNH0.MPyKXuzUlb-F_-d5h1wGcc3huJ-d_OD6B2YH0TiL9RE',
  );

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,      
      routerConfig: _appRouter,
      title: 'Katahari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    );
  }
}
