import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katahari/config/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview/device_preview.dart'; // import Device Preview
import 'firebase_options.dart';

// Router dibuat SEKALI
final _appRouter = createRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://kbyjftdcdcqhwvictpjd.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(
    DevicePreview(
      enabled: true, // set false jika mau matikan
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
