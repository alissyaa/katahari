import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:katahari/pages/forgot_page.dart';
import 'package:katahari/pages/signup_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signIn() async {
    // Validasi untuk email dan password
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Input Tidak Lengkap",
        "Harap isi email dan password.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
      return;
    }

    // Logika sign-in dengan email dan password
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.offAll(const Wrapper());
      // Navigasi ke halaman utama setelah berhasil login

      Get.snackbar(
          "Sukses", "Login berhasil!", snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.back(); // Tutup dialog loading
      String errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = "Email atau password yang Anda masukkan salah.";
      }
      Get.snackbar("Login Gagal", errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: SafeArea(
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height - MediaQuery
              .of(context)
              .padding
              .top,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        "Hey, There,\nYou're Back!",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                            fontSize: 28, // Ukuran font ini tetap
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                    ),
                    const SizedBox(height: 35),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(hint: "Email"),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _buildInputDecoration(hint: "Password"),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Get.to(() => const ForgotPage()),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: GoogleFonts.poppins(fontSize: 16)),
                        // <-- DIUBAH MENJADI 16
                        TextButton(
                          onPressed: () => Get.to(() => const SignupPage()),
                          style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 5)),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // ===== LOGIN BUTTON =====
                    ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffb0c4de),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2.5),
      ),
    );
  }
}