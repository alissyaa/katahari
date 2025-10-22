import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:katahari/wrapper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  signUp() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    Get.offAll(const Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFFE7AD),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                    hintText: 'Enter Email',
                    hintStyle: GoogleFonts.poppins()
                ),
              ),
              TextField(
                controller: passwordController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                    hintText: 'Enter Password',
                    hintStyle: GoogleFonts.poppins()
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: signUp,
                  child: Text("Sign Up", style: GoogleFonts.poppins(),)
              ),
            ],
          ),
        )
    );
  }
}
