import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JournalCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onTap;

  const JournalCard({super.key, required this.entry, this.onTap});

  // --- Daftar Aset Mood ---
  static const Map<String, String> _moodAssets = {
    'happy': 'assets/mood_happy.png',
    'flat': 'assets/mood_flat.png',
    'sad': 'assets/mood_sad.png',
    'angry': 'assets/mood_angry.png',
  };

  @override
  Widget build(BuildContext context) {
    final imageUrls = entry['imageUrls'] as List?;
    final firstImage = imageUrls != null && imageUrls.isNotEmpty ? imageUrls.first : null;
    final mood = entry['mood'] as String? ?? 'happy';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: firstImage == null ? const Color(0xFFF0F0F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          image: firstImage != null
              ? DecorationImage(
                  image: NetworkImage(firstImage),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              if (firstImage != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: firstImage == null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (firstImage == null)
                      Align(
                        alignment: Alignment.topRight,
                        // --- PERBAIKAN DI SINI: Menggunakan Image.asset ---
                        child: Image.asset(
                          _moodAssets[mood] ?? _moodAssets['happy']!,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['title'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: firstImage != null ? Colors.white : Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry['date'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: firstImage != null ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (firstImage != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    // --- PERBAIKAN DI SINI: Menggunakan Image.asset ---
                    child: Image.asset(
                      _moodAssets[mood] ?? _moodAssets['happy']!,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
