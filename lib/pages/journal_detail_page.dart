import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // --- FUNGSI BARU UNTUK MENGHAPUS SEMUA DATA JURNAL ---
  Future<void> _deleteJournal(BuildContext context, List<String> imageUrls) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Hapus gambar dari Supabase Storage
      if (imageUrls.isNotEmpty) {
        final supabase = Supabase.instance.client;
        // Ekstrak path file dari URL
        final filePaths = imageUrls.map((url) {
          final uri = Uri.parse(url);
          // Path dimulai setelah nama bucket (contoh: /public/journal_images/....)
          // Kita perlu menghapus bagian awal ini dari path
          final pathSegments = uri.pathSegments;
          // Asumsi: pathSegments akan berisi ['storage', 'v1', 'object', 'public', 'journal_images', ...sisa path]
          if (pathSegments.length > 5) {
            return pathSegments.sublist(5).join('/');
          }
          return '';
        }).where((p) => p.isNotEmpty).toList();

        if (filePaths.isNotEmpty) {
          await supabase.storage.from('journal_images').remove(filePaths);
        }
      }

      // 2. Hapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .doc(journalId)
          .delete();

      // 3. Kembali ke halaman utama setelah berhasil
      if (context.mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading
        context.pop(); // Kembali dari halaman detail
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Tutup dialog loading jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus jurnal: $e")),
        );
      }
    }
  }

  // --- FUNGSI BARU UNTUK DIALOG KONFIRMASI ---
  void _showDeleteConfirmationDialog(BuildContext context, List<String> imageUrls) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Jurnal'),
          content: const Text('Anda yakin ingin menghapus jurnal ini secara permanen?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi
                _deleteJournal(context, imageUrls); // Mulai proses hapus
              },
            ),
          ],
        );
      },
    );
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getJournalStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: const Center(child: Text("Entri jurnal tidak ditemukan atau sudah dihapus.")),
            );
          }

          final data = snapshot.data!.data()!;
          final title = data['title'] ?? 'Tanpa Judul';
          final description = data['description'] ?? '';
          final timestamp = data['createdAt'] as Timestamp?;
          final imageUrls = List<String>.from(data['imageUrls'] ?? []);
          final stickersData = List<Map<String, dynamic>>.from(data['stickers'] ?? []);
          final activeStickers = stickersData.map((d) => Sticker.fromJson(d)).toList();
          final mood = data['mood'] ?? 'happy';
          final paperColor = Color(data['paperColor'] as int? ?? Colors.white.value);

          return Scaffold(
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
                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              actions: [
                // --- PERUBAHAN ICON DAN FUNGSI HAPUS ---
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black, size: 26),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, imageUrls);
                  },
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
            body: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 100),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: paperColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 50,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageGrid(imageUrls),
                          if (imageUrls.isNotEmpty) const SizedBox(height: 16),
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
                            style: GoogleFonts.poppins(height: 1.6),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageWidgets = imageUrls.map((url) => _buildGridItem(url)).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SizedBox(
        height: 250,
        child: _buildLayoutForImages(imageWidgets),
      ),
    );
  }

  Widget _buildLayoutForImages(List<Widget> items) {
    switch (items.length) {
      case 1:
        return items[0];
      case 2:
        return Row(children: [Expanded(child: items[0]), const SizedBox(width: 2), Expanded(child: items[1])]);
      case 3:
        return Row(children: [
          Expanded(flex: 2, child: items[0]),
          const SizedBox(width: 2),
          Expanded(flex: 1, child: Column(children: [Expanded(child: items[1]), const SizedBox(height: 2), Expanded(child: items[2])])),
        ]);
      case 4:
        return Column(children: [
          Expanded(child: Row(children: [Expanded(child: items[0]), const SizedBox(width: 2), Expanded(child: items[1])])),
          const SizedBox(height: 2),
          Expanded(child: Row(children: [Expanded(child: items[2]), const SizedBox(width: 2), Expanded(child: items[3])])),
        ]);
      default:
        return items.isNotEmpty ? items[0] : const SizedBox.shrink();
    }
  }

  Widget _buildGridItem(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400)),
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
