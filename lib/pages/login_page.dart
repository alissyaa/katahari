import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/config/routes.dart';
import 'package:video_player/video_player.dart';
import 'package:katahari/constant/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late VideoPlayerController _eyesController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _eyesController = VideoPlayerController.asset('assets/mata_tiga.mp4')
      ..initialize().then((_) {
        setState(() {});
        _eyesController.play();
      });
    _eyesController.setLooping(false);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _eyesController.dispose();
    _fadeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
      ));
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      context.go(AppRoutes.journal);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login successful!"),
      ));
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = "The email or password you entered is incorrect.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: AppColors.merah,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 40),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hey, There,\nYou're Back!",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 35),

                    _buildTextField("Email", emailController),
                    const SizedBox(height: 15),
                    _buildTextField("Password", passwordController, obscure: true),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => context.go('/forgot'),
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            color: AppColors.abumuda,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: signIn,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, TextEditingController controller,
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
                color: hasFocus ? AppColors.button : AppColors.secondary,
                width: hasFocus ? 2.5 : 2,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: AppColors.abumuda),
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
