import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'add_journal_page.dart' show Sticker;

class JournalDetailPage extends StatelessWidget {
  final String journalId;
  const JournalDetailPage({super.key, required this.journalId});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getJournalStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .doc(journalId)
        .snapshots();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Tanggal tidak diketahui";
    return DateFormat('E, d MMMM yyyy').format(timestamp.toDate());
  }

  static const Map<String, String> _moodAssets = {
    'happy': 'assets/mood_happy.png',
    'flat': 'assets/mood_flat.png',
    'sad': 'assets/mood_sad.png',
    'angry': 'assets/mood_angry.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Journal',
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/edit_journal/$journalId');
        },
        backgroundColor: const Color(0xFFB0C4DE),
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 2),
        ),
        child: const Icon(Icons.edit, color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getJournalStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Entri jurnal tidak ditemukan."));
          }

          final data = snapshot.data!.data()!;
          final title = data['title'] ?? 'Tanpa Judul';
          final description = data['description'] ?? '';
          final timestamp = data['createdAt'] as Timestamp?;
          final imageUrls = List<String>.from(data['imageUrls'] ?? []);
          final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 16.0;
          final textColor = Color(data['textColor'] as int? ?? Colors.black87.value);
          final mood = data['mood'] ?? 'happy';
          
          final stickersData = List<Map<String, dynamic>>.from(data['stickers'] ?? []);
          final activeStickers = stickersData.map((d) => Sticker.fromJson(d)).toList();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 50,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    // --- PERBAIKAN DI SINI ---
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Memaksa tinggi minimal konten agar kartu selalu terlihat panjang
                        minHeight: MediaQuery.of(context).size.height * 0.95,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrls.first,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  loadingBuilder: (context, child, progress) =>
                                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _formatTimestamp(timestamp),
                                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                _moodAssets[mood] ?? _moodAssets['happy']!,
                                width: 32,
                                height: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: fontSize,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildTag(Icons.location_on_outlined, 'Roblox'),
                              const SizedBox(width: 10),
                              _buildTag(Icons.music_note_outlined, 'Winner Takes It All - ABBA'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ...activeStickers.map((sticker) {
                return Positioned(
                  left: sticker.position.dx,
                  top: sticker.position.dy,
                  child: Image.asset(
                    sticker.assetPath,
                    width: sticker.size,
                    height: sticker.size,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400)
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
