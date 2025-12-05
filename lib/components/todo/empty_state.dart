import 'package:flutter/material.dart';
import 'package:katahari/constant/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String status;

  const EmptyStateWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String assetImage;
    String message;

    switch (status.toLowerCase()) {
      case 'ongoing':
        assetImage = "assets/empty_ongoing.png";
        message = "No tasks to accomplish";
        break;
      case 'completed':
        assetImage = "assets/empty_completed.png";
        message = "No task completed.";
        break;
      case 'missed':
        assetImage = "assets/empty_missed.png";
        message = "No missed tasks.";
        break;
      default:
        assetImage = "assets/empty_ongoing.png";
        message = "No data";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Image.asset(assetImage, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.abumuda,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
