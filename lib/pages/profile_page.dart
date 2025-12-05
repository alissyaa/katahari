import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';
import 'edit_profile_page.dart'; // pastikan file ini ada

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // Stream untuk mendengarkan data profil secara real-time
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getProfileStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  // Stream untuk data jurnal (untuk hitungan mood)
  Stream<QuerySnapshot<Map<String, dynamic>>> _getJournalsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .snapshots();
  }

  // Navigasi ke halaman edit profile
  void _navigateToEditPage({
    required String name,
    required String birthday,
    required String mbti,
    required Color cardColor,
    required Color headerColor,
    required String? imageUrl,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: name,
          currentBirthday: birthday,
          currentMbti: mbti,
          currentCardColor: cardColor,
          currentHeaderColor: headerColor,
          currentImageUrl: imageUrl,
        ),
      ),
    );

    // Jika result true, paksa rebuild ProfilePage
    if (result == true) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profileData =
              snapshot.data?.data()?['profile'] as Map<String, dynamic>? ?? {};
          final name = profileData['name'] as String? ??
              user.displayName ??
              user.email?.split('@')[0] ??
              'User';
          final birthday = profileData['birthday'] as String? ?? "-";
          final mbti = profileData['mbti'] as String? ?? "-";
          final cardColor = Color(
              profileData['cardColor'] as int? ?? AppColors.kream.value);
          final headerColor = Color(
              profileData['headerColor'] as int? ?? AppColors.primary.value);
          final imageUrl = profileData['imageUrl'] as String?;

          return _buildProfileContent(
            name: name,
            birthday: birthday,
            mbti: mbti,
            cardColor: cardColor,
            headerColor: headerColor,
            imageUrl: imageUrl,
          );
        },
      ),
    );
  }

  Widget _buildProfileContent({
    required String name,
    required String birthday,
    required String mbti,
    required Color cardColor,
    required Color headerColor,
    required String? imageUrl,
  }) {
    String formattedDate =
    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    String capitalizedName =
    name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'User';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $capitalizedName',
                      style: GoogleFonts.poppins(
                          fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // Icon settings
                InkWell(
                  onTap: () {
                    GoRouter.of(context).go('/settings/settings_page');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Icon(
                    Icons.settings_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Card
            GestureDetector(
              onTap: () {
                _navigateToEditPage(
                  name: name,
                  birthday: birthday,
                  mbti: mbti,
                  cardColor: cardColor,
                  headerColor: headerColor,
                  imageUrl: imageUrl,
                );
              },
              child: _buildProfileCard(
                name: name,
                birthday: birthday,
                mbti: mbti,
                cardColor: cardColor,
                headerColor: headerColor,
                imageUrl: imageUrl,
              ),
            ),

            const SizedBox(height: 20),
            _buildMoodTrackerTitle(name),
            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getJournalsStream(),
              builder: (context, snapshot) {
                int happyCount = 0, sadCount = 0, neutralCount = 0, angryCount = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final mood = doc.data()['mood'] as String?;
                    switch (mood) {
                      case 'happy':
                        happyCount++;
                        break;
                      case 'sad':
                        sadCount++;
                        break;
                      case 'flat':
                        neutralCount++;
                        break;
                      case 'angry':
                        angryCount++;
                        break;
                    }
                  }
                }
                return _buildAllMoodRows(
                  happy: happyCount,
                  neutral: neutralCount,
                  sad: sadCount,
                  angry: angryCount,
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String birthday,
    required String mbti,
    required Color cardColor,
    required Color headerColor,
    required String? imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              border:
              Border(bottom: BorderSide(color: AppColors.secondary, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.auto_awesome, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text('katahari.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    _buildEmojiCircle("assets/mood_happy.png", AppColors.screen1),
                    const SizedBox(width: 6),
                    _buildEmojiCircle("assets/mood_flat.png", AppColors.screen2),
                    const SizedBox(width: 6),
                    _buildEmojiCircle("assets/mood_sad.png", AppColors.button),
                    const SizedBox(width: 6),
                    _buildEmojiCircle("assets/mood_angry.png", AppColors.merah),
                  ],
                ),
              ],
            ),
          ),

          // profile body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: AppColors.primary,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const Center(
                          child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stack) =>
                          Icon(Icons.person, size: 32, color: AppColors.secondary),
                    )
                        : Icon(Icons.person, size: 32, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name\n$name",
                          style: GoogleFonts.poppins(
                              height: 1.5, color: AppColors.secondary)),
                      const SizedBox(height: 4),
                      Text("Birthday\n$birthday",
                          style: GoogleFonts.poppins(
                              height: 1.5, color: AppColors.secondary)),
                      const SizedBox(height: 4),
                      Text("MBTI\n$mbti",
                          style: GoogleFonts.poppins(
                              height: 1.5, color: AppColors.secondary)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMoodRows({
    required int happy,
    required int neutral,
    required int sad,
    required int angry,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('happy'),
          child: _buildMoodRow(
            mood: 'happy',
            iconData: Icons.sentiment_very_satisfied,
            backgroundColor: AppColors.screen1,
            count: happy,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('flat'),
          child: _buildMoodRow(
            mood: 'flat',
            iconData: Icons.sentiment_neutral,
            backgroundColor: AppColors.screen2,
            count: neutral,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('sad'),
          child: _buildMoodRow(
            mood: 'sad',
            iconData: Icons.sentiment_very_dissatisfied,
            backgroundColor: AppColors.button,
            count: sad,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('angry'),
          child: _buildMoodRow(
            mood: 'angry',
            iconData: Icons.sentiment_dissatisfied,
            backgroundColor: AppColors.merah,
            count: angry,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrackerTitle(String name) {
    String possessiveName =
    name.toLowerCase().endsWith('s') ? "$name' Mood Tracker" : "$name's Mood Tracker";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(possessiveName,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: const Color(0xFF0C1212))),
    );
  }

  Widget _buildMoodRow({
    required String imagePath,
    required String mood,
    required IconData iconData,
    required Color backgroundColor,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _navigateToJournalMoodPage(mood),
        borderRadius: BorderRadius.circular(50),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(color: Colors.black, width: 1.5)),
              child: Icon(iconData, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black, width: 1.5)),
                child: Center(
                    child: Text(count.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black))),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(color: Colors.black, width: 1.5)),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiCircle(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: AppColors.secondary)),
      child: Icon(icon, color: AppColors.secondary, size: 14),
    );
  }

  void _navigateToJournalMoodPage(String mood) {
    context.push('/profile/mood_journal_list/$mood');
  }
}
