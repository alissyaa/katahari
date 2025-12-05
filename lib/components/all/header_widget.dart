import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/constant/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  final String userName;
  final String date;

  const HeaderWidget({
    super.key,
    required this.userName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${userName[0].toUpperCase()}${userName.substring(1)}',
          style: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.abumuda,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
