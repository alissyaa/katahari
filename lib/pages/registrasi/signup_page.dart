import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:katahari/constant/app_colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late VideoPlayerController _eyesController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _eyesController = VideoPlayerController.asset('assets/mata_dua.mp4')
      ..initialize().then((_) {
        setState(() {});
        _eyesController.play();
      });
    _eyesController.setLooping(false);

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _eyesController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (nickname.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.merah,
        colorText: AppColors.primary,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(nickname);
      await userCredential.user!.reload();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nickname': nickname,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      context.go('/journal');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login successful!"),
      ));
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = "Email already in use";
      } else if (e.code == 'weak-password') {
        message = "Password too weak (min 6 characters)";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else {
        message = e.message ?? "Sign up failed";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppColors.merah,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen2,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                  child: _eyesController.value.isInitialized
                      ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: AspectRatio(
                      aspectRatio: _eyesController.value.aspectRatio,
                      child: VideoPlayer(_eyesController),
                    ),
                  )
                      : const SizedBox(height: 240),
                ),

                /// TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Ready to Write \nYours?",
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildTextField("Your nickname", nicknameController),
                      const SizedBox(height: 16),
                      _buildTextField("Email", emailController),
                      const SizedBox(height: 16),
                      _buildTextField("Password", passwordController, obscure: true),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.abumuda,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              "Log In",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.secondary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        onPressed: signUp,
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool obscure = false}) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: hasFocus
                    ? AppColors.button
                    : AppColors.secondary,
                width: hasFocus ? 2.5 : 2,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.poppins(color: AppColors.secondary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                GoogleFonts.poppins(color: AppColors.abumuda),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: InputBorder.none,
              ),
            ),
          );
        },
      ),
    );
  }
}
