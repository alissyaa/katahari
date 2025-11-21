import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "User";
  String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBarContent(),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 28),
              _buildMoodTrackerTitle(),
              const SizedBox(height: 20),
              // Panggil _buildMoodRow dengan warna yang sesuai
              _buildMoodRow(
                iconData: Icons.sentiment_very_satisfied,
                color: const Color(0xFFAEE0A6),
                backgroundColor: const Color(0xFFAEE0A6),
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_neutral,
                color: const Color(0xFFF8DDA9),
                backgroundColor: const Color(0xFFF8DDA9),
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_very_dissatisfied,
                color: const Color(0xFFF0B3B1),
                backgroundColor: const Color(0xFFF0B3B1),
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_dissatisfied,
                color: const Color(0xFFAECFEE),
                backgroundColor: const Color(0xFFAECFEE),
                count: 0,
              ),
              const SizedBox(height: 40), // Ruang di bagian bawah
            ],
          ),
        ),
      ),
      // --- PERUBAHAN DI SINI ---
      // floatingActionButtonLocation dan floatingActionButton telah dihapus
    );
  }

  // WIDGET HELPERS

  Widget _buildAppBarContent() {
    return const SizedBox(height: 16);
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName',
              style: GoogleFonts.poppins(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: const Icon(
              Icons.settings_outlined, size: 30, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          // Navbar putih di dalam kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'katahari.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                // Emoji diberi latar belakang solid seperti di Mood Tracker
                Row(
                  children: [
                    _buildEmojiCircle(Icons.sentiment_very_satisfied,
                        const Color(0xFFAEE0A6)),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_neutral, const Color(0xFFF8DDA9)),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(Icons.sentiment_very_dissatisfied,
                        const Color(0xFFF0B3B1)),
                  ],
                ),
              ],
            ),
          ),
          // Konten di bawah navbar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Placeholder Foto
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                        Icons.add_a_photo, size: 32, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                // Detail Teks
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name\n-", style: GoogleFonts.poppins(height: 1.5)),
                    const SizedBox(height: 4),
                    Text(
                        "Birthday\n-", style: GoogleFonts.poppins(height: 1.5)),
                    const SizedBox(height: 4),
                    Text("MBTI\n-", style: GoogleFonts.poppins(height: 1.5)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk emoji di dalam profile card
  Widget _buildEmojiCircle(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 14),
    );
  }

  Widget _buildMoodTrackerTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        "User's Mood Tracker",
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: const Color(0xFF0C1212)),
      ),
    );
  }

  Widget _buildMoodRow({
    required IconData iconData,
    required Color color,
    required Color backgroundColor,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // 1. Ikon Mood di dalam lingkaran solid
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor, // Warna latar sama dengan container
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            // Ikon emoji dalam nya hitam
            child: Icon(iconData, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 12),

          // Container yang hanya berisi angka
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    // Angka "0" nya hitam
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Tombol panah dengan latar belakang solid
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor, // Warna latar sama dengan container
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            // Ikon panah nya hitam
            child: const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

// --- FUNGSI-FUNGSI DI BAWAH INI TELAH DIHAPUS ---
// _buildBottomNavBar()
// _buildBottomNavItem()
}