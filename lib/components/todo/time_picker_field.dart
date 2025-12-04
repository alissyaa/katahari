import 'package:flutter/material.dart';
import 'package:katahari/utils/date_formatter.dart';
import 'package:katahari/constant/app_colors.dart';

class TimePickerField extends StatelessWidget {
  final DateTime? selectedTime;
  final Function(DateTime) onTimeSelected;

  const TimePickerField({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  Future<void> pickTime(BuildContext context) async {
    final initialTime = selectedTime == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: selectedTime!.hour, minute: selectedTime!.minute);

    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (result != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        result.hour,
        result.minute,
      );

      onTimeSelected(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pickTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.abumuda, // Grey → abumuda
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedTime == null
                  ? "Select deadline time"
                  : DateFormatter.formatTime(selectedTime!),
              style: TextStyle(
                fontSize: 16,
                color: selectedTime == null
                    ? AppColors.abumuda.withOpacity(0.7)
                    : AppColors.secondary,
              ),
            ),
            Icon(
              Icons.access_time_outlined,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
