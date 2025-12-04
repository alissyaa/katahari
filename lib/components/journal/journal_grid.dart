import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/components/journal/journal_card.dart';

class JournalGrid extends StatelessWidget {
  final String searchQuery;
  final String? moodFilter;

  const JournalGrid({
    super.key,
    required this.searchQuery,
    this.moodFilter,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to see your journal."));
    }

    // Query dasar
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .orderBy('createdAt', descending: true);

    // Filter mood
    if (moodFilter != null) {
      query = query.where('mood', isEqualTo: moodFilter);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        var journalDocs = snapshot.data?.docs ?? [];

        // Search
        if (searchQuery.isNotEmpty) {
          journalDocs = journalDocs.where((doc) {
            final data = doc.data();
            final title = (data['title'] as String?)?.toLowerCase() ?? '';
            return title.contains(searchQuery.toLowerCase());
          }).toList();
        }

        if (journalDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No journals found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        // --- PENGHITUNGAN KARD WIDTH & HEIGHT DARI KODE PERTAMA ---
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = 60.0;
        final spacing = 15.0;
        final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;
        final imageCardHeight = cardWidth / 0.75;

        // --- LAYOUT MASONRY GRID (dari kode kedua) ---
        return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: journalDocs.length,
          itemBuilder: (context, index) {
            final doc = journalDocs[index];
            final data = doc.data();

            final entry = {
              'id': doc.id,
              'title': data['title'] ?? 'No Title',
              'description': data['description'] ?? '',
              'date': (data['createdAt'] as Timestamp?)?.toDate().toString() ?? '',
              'imageUrls': List<String>.from(data['imageUrls'] ?? []),
              'mood': data['mood'] ?? 'happy',
            };

            final bool hasImage = (entry['imageUrls'] as List).isNotEmpty;

            // JournalCard
            final card = JournalCard(
              entry: entry,
              onTap: () {
                context.push('/journal_detail/${doc.id}');
              },
            );

            return SizedBox(
              width: cardWidth,
              height: hasImage ? imageCardHeight : null,
              child: card,
            );
          },
        );
      },
    );
  }
}
