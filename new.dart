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
  // Controller untuk halaman utama
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Fungsi untuk proses sign-in dengan Firebase
  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Jika login berhasil, panggil popup
      showLoginPopup(context);
    } on FirebaseAuthException catch (e) {
      // Jika login gagal, tampilkan pesan error
      Get.snackbar(
        "Login Gagal",
        e.message ?? "Email atau password salah. Silakan coba lagi.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi untuk menampilkan popup dialog sesuai desain UI
  void showLoginPopup(BuildContext context) {
    // Controller khusus untuk field di dalam popup
    TextEditingController nicknameController = TextEditingController();
    TextEditingController popupEmailController = TextEditingController();
    TextEditingController popupPasswordController = TextEditingController();

    // Autofill email dari halaman login utama
    popupEmailController.text = emailController.text;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xfff7f7f7),
          // Warna background sesuai UI
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Agar elemen mengisi lebar
                children: [
                  // ===== ICON MATA & HURUF K =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.lightbulb_outline, size: 40,
                          color: Colors.black54),
                      Icon(Icons.lightbulb, size: 50, color: Color(0xffadd8e6)),
                      // Warna biru muda
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "K",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.zillaSlab( // Font yang lebih mirip
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ===== TITLE TEXT =====
                  Text(
                    "Hey, There,\nYou're Back!",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.bold, height: 1.2
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ===== NICKNAME FIELD =====
                  TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      hintText: "Your nickname",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none, // Hapus border default
                      ),
                      enabledBorder: OutlineInputBorder( // Border saat tidak di-fokus
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder( // Border saat di-fokus
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ===== EMAIL FIELD =====
                  TextField(
                    controller: popupEmailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ===== FORGOT PASSWORD =====
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog dulu
                        Get
                            .to(() => const ForgotPage()); // Buka halaman forgot password
                      },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 5)),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== LOGIN BUTTON =====
                  ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika untuk login dari popup jika perlu
                      Get.back(); // Menutup popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffadd8e6),
                      // Warna biru muda
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.black,
                              width: 1.5) // Border hitam
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text("Log In", style: GoogleFonts.poppins(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),

                  // ===== SIGNUP =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: GoogleFonts.poppins(fontSize: 12)),
                      TextButton(
                        onPressed: () {
                          Get.back(); // Tutup dialog dulu
                          Get
                              .to(() => const SignupPage()); // Buka halaman sign up
                        },
                        child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(fontWeight: FontWeight
                                .bold, color: Colors.black, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Halaman login utama yang sederhana
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Katahari Login",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Login", style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
