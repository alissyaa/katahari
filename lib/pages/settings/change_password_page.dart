import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/constant/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _previousPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _previousPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No user is currently signed in.',
        );
      }

      final previousPassword = _previousPasswordController.text;
      final newPassword = _newPasswordController.text;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: previousPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        context.go('/profile');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Previous password is incorrect.';
          break;
        case 'weak-password':
          message = 'The new password is too weak (at least 6 characters).';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      if (mounted) {
        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                label: "Previous Password",
                controller: _previousPasswordController,
                hint: "Enter Previous Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your previous password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: "New Password",
                controller: _newPasswordController,
                hint: "Enter New Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                hint: "Enter Confirm Password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(
                      color: AppColors.merah,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 150,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _buildSaveButton(),
                ),
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
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.secondary,
          size: 24,
        ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: AppColors.secondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.abumuda.withOpacity(0.5),
            ),
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
              borderSide: BorderSide(color: AppColors.button, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.merah, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.merah, width: 2.0),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _changePassword,
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
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}