import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constant/app_colors.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  final Future<void> Function() onPickDate;
  final Future<void> Function() onPickTime;

  const CustomDateTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPickDate,
            child: _roundedContainer(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                    : 'Date',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: selectedDate != null
                      ? AppColors.secondary
                      : AppColors.abumuda,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: GestureDetector(
            onTap: onPickTime,
            child: _roundedContainer(
              child: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Time',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: selectedTime != null
                      ? AppColors.secondary
                      : AppColors.abumuda,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roundedContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: child,
    );
  }
}
