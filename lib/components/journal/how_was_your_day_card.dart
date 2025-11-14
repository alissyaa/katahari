import 'package:flutter/material.dart';

class HowWasYourDayCard extends StatelessWidget {
  const HowWasYourDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement action on tap, e.g., navigate to a new page.
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          'assets/header_journal.png', // Assuming .png, change if needed
        ),
      ),
    );
  }
}
