import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const JournalCard({super.key, required this.entry});

  IconData getMoodIcon(String? mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Color getMoodColor(String? mood) {
    switch (mood) {
      case 'happy':
        return Colors.green;
      case 'angry':
        return Colors.red;
      case 'neutral':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: entry['image'] == null
            ? const Color(0xFFF0F0F0)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        image: entry['image'] != null
            ? DecorationImage(
                image: NetworkImage(entry['image']),
                fit: BoxFit.cover)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            if (entry['image'] != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: entry['image'] == null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry['image'] == null)
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(getMoodIcon(entry['mood']), color: getMoodColor(entry['mood']), size: 30),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['title'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: entry['image'] != null
                                ? Colors.white
                                : Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry['date'],
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: entry['image'] != null
                                ? Colors.white70
                                : Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (entry['image'] != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle),
                    child: Icon(getMoodIcon(entry['mood']),
                        color: getMoodColor(entry['mood']), size: 24)),
              ),
          ],
        ),
      ),
    );
  }
}
