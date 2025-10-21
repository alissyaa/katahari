import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:katahari/wrapper.dart';
import 'package:get/get.dart';

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
    Get.offAll(Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Sign Up"),),
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

              ElevatedButton(onPressed: (()=>signUp()), child: Text("Sign Up"),),
            ],
          ),
        )
    );
  }
}
