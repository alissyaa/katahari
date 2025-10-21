import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:katahari/pages/forgot_page.dart';
import 'package:katahari/pages/signup_page.dart';

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
      appBar: AppBar(title: Text("Login"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Enter Email'),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(hintText: 'Enter Password'),
          ),

          ElevatedButton(onPressed: (()=>signIn()), child: Text("Login")),
          SizedBox(height: 30,),
          ElevatedButton(onPressed: (()=>Get.to(SignupPage())), child: Text("Register Now")),
          SizedBox(height: 30,),
          ElevatedButton(onPressed: (()=>Get.to(ForgotPage())), child: Text("Forgot Password?")),
        ],
        ),
      )
    );
  }
}
