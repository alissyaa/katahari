import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:katahari/pages/forgot_page.dart';
import 'package:katahari/pages/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login", style: GoogleFonts.poppins()),
        titleTextStyle: GoogleFonts.poppins(),
      ),
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
              hintStyle: GoogleFonts.poppins(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: signIn, child: Text("Login", style: GoogleFonts.poppins())),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: (()=>Get.to(const SignupPage())), child: Text("Register Now", style: GoogleFonts.poppins())),
          const SizedBox(height: 20,),
          ElevatedButton(onPressed: (()=>Get.to(const ForgotPage())), child: Text("Forgot Password?", style: GoogleFonts.poppins())),
        ],
        ),
      )
    );
  }
}
