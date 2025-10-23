import 'package:flutter/material.dart';

class AddJournalCard extends StatelessWidget {
  final String? image;

  const AddJournalCard({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
            image: DecorationImage(
                image: NetworkImage(image ?? 'https://i.pinimg.com/564x/ac/5c/45/ac5c453549926868a12515b671758655.jpg'),
                fit: BoxFit.cover,
                opacity: 0.8)),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.8),
                shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}
