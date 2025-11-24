import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/constant/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _previousPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery
                .of(context)
                .size
                .height -
                AppBar().preferredSize.height -
                MediaQuery
                    .of(context)
                    .padding
                    .top,
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                _buildPasswordField(
                    label: "Previous Password",
                    controller: _previousPasswordController),
                const SizedBox(height: 16),
                _buildPasswordField(
                    label: "New Password", controller: _newPasswordController),
                const SizedBox(height: 16),
                _buildPasswordField(
                    label: "Confirm Password",
                    controller: _confirmPasswordController),
                const Spacer(),
                _buildSaveButton(),
                const SizedBox(height: 370),
              ],
            ),
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
        icon:
        Icon(Icons.arrow_back_ios_new, color: AppColors.secondary, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Change Password",
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPasswordField(
      {required String label, required TextEditingController controller}) {
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
          obscureText: true,
          style: TextStyle(color: AppColors.secondary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primary,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.button, width: 2.0),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully!')),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.secondary, width: 1.5),
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