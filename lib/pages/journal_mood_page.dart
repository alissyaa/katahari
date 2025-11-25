import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/components/journal/journal_grid.dart';
import 'package:katahari/constant/app_colors.dart';

// Halaman ini adalah versi simpel yang hanya menampilkan grid jurnal berdasarkan mood.
class JournalMoodPage extends StatelessWidget {
  // Menggunakan parameter 'mood' yang konsisten dengan ProfilePage.
  final String mood;

  const JournalMoodPage({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';

    // Mengubah string mood menjadi berawalan huruf kapital (misal: "happy" -> "Happy").
    final capitalizedMood = '${mood[0].toUpperCase()}${mood.substring(1)}';

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          // Judul dinamis sesuai dengan user dan mood yang dipilih.
          "$userName's $capitalizedMood",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        // Langsung tampilkan JournalGrid dengan filter mood yang sudah dikirim.
        child: JournalGrid(
          searchQuery: '', // Tidak ada fungsi search di halaman ini.
          moodFilter: mood,
        ),
      ),
    );
  }
}