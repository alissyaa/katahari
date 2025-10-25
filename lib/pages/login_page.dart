import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:katahari/pages/forgot_page.dart';
import 'package:katahari/pages/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/wrapper.dart';
import 'package:video_player/video_player.dart';

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

    // Video controller
    _eyesController = VideoPlayerController.asset('assets/mata_tiga.mp4')
      ..initialize().then((_) {
        setState(() {});
        _eyesController.play();
      });
    _eyesController.setLooping(false);

    // Fade animation
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
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
      Get.snackbar(
        "Please fill all fields",
        "Please enter your email and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAll(const Wrapper());
      Get.snackbar(
        "Success",
        "Login successful!",
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.back();
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = "The email or password you entered is incorrect.";
      }
      Get.snackbar(
        "Login unsuccessful!",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F1F2),
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
                    : const SizedBox(height: 240), // Placeholder to prevent layout jump
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Hey, There,\nYou're Back!",
                      style: GoogleFonts.poppins(
                          fontSize: 30, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 35),

                    _buildTextField("Email", emailController),
                    const SizedBox(height: 15),
                    _buildTextField("Password", passwordController, obscure: true),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => Get.to(() => const ForgotPage()),
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Signup link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                        TextButton(
                          onPressed: () => Get.to(() => const SignupPage()),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    // Login button (match text field style)
                    const SizedBox(height: 32),OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFA9CCEF),
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Color(0xFF0C1212)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF84B2DF); // darker blue when pressed
                            }
                            return null;
                          },
                        ),
                      ),
                      onPressed: signIn,
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C1212),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: hasFocus ? Colors.blue : Colors.black,
                width: hasFocus ? 2.5 : 2,
              ),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
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
