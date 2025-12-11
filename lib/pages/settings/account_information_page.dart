import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/constant/app_colors.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    _usernameController = TextEditingController(
      text: user?.displayName ?? user?.email?.split('@')[0] ?? '',
    );

    _emailController = TextEditingController(
      text: user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(context),

      // 🔥 BUTTON DIPINDAH KE SINI
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildSaveButton(),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField(
                label: "Username",
                controller: _usernameController,
                hint: "Enter username",
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: "Email",
                controller: _emailController,
                hint: "Enter email",
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: AppColors.secondary, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Account Information",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.secondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: AppColors.secondary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.abumuda),
            filled: true,
            fillColor: AppColors.primary,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.button, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            await user.updateDisplayName(_usernameController.text.trim());
            await user.reload(); // Refresh user
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Information updated successfully!')),
          );

          Navigator.pop(context, true); // kasih sinyal ke previous page
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.secondary, width: 2),
          ),
          elevation: 0,
        ),
        child: Text(
          "Save",
          style: GoogleFonts.poppins(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
      ),
    );
  }
}
