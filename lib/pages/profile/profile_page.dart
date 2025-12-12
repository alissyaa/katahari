import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';
import 'package:katahari/components/all/header_widget.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getProfileStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getJournalsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journals')
        .snapshots();
  }

  void _navigateToEditPage({
    required String name,
    required String birthday,
    required String mbti,
    required Color cardColor,
    required Color headerColor,
    required String? imageUrl,
  }) {
    context.push('/profile/edit', extra: {
      'name': name,
      'birthday': birthday,
      'mbti': mbti,
      'cardColor': cardColor,
      'headerColor': headerColor,
      'imageUrl': imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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

          final displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';

          final birthday = profileData['birthday'] ?? "-";
          final mbti = profileData['mbti'] ?? "-";

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
            displayName: displayName,
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
    required String displayName,
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
              children: [
                Expanded(
                  child: HeaderWidget(
                    userName: displayName,
                    date: formattedDate,
                  ),
                ),
                InkWell(
                  onTap: () {
                    GoRouter.of(context).go('/settings/settings_page');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Icon(
                    Icons.settings_outlined,
                    size: 30,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

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
                int happy = 0, sad = 0, flat = 0, angry = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final mood = doc['mood'];
                    switch (mood) {
                      case 'happy':
                        happy++;
                        break;
                      case 'flat':
                        flat++;
                        break;
                      case 'sad':
                        sad++;
                        break;
                      case 'angry':
                        angry++;
                        break;
                    }
                  }
                }

                return _buildAllMoodRows(
                  happy: happy,
                  neutral: flat,
                  sad: sad,
                  angry: angry,
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
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 20, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'katahari.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.secondary),
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
                      loadingBuilder:
                          (context, child, progress) =>
                      progress == null
                          ? child
                          : const Center(
                          child:
                          CircularProgressIndicator()),
                      errorBuilder: (context, error, stack) =>
                          Icon(Icons.person,
                              size: 32, color: AppColors.secondary),
                    )
                        : Icon(Icons.person,
                        size: 32, color: AppColors.secondary),
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

  Widget _buildMoodTrackerTitle(String name) {
    String possessive =
    name.toLowerCase().endsWith('s') ? "$name' Mood Tracker" : "$name's Mood Tracker";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Text(
        possessive,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, color: AppColors.secondary),
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
        _buildMoodRow(
          imagePath: "assets/mood_happy.png",
          mood: 'happy',
          backgroundColor: AppColors.screen1,
          count: happy,
        ),
        _buildMoodRow(
          imagePath: "assets/mood_flat.png",
          mood: 'flat',
          backgroundColor: AppColors.screen2,
          count: neutral,
        ),
        _buildMoodRow(
          imagePath: "assets/mood_sad.png",
          mood: 'sad',
          backgroundColor: AppColors.button,
          count: sad,
        ),
        _buildMoodRow(
          imagePath: "assets/mood_angry.png",
          mood: 'angry',
          backgroundColor: AppColors.merah,
          count: angry,
        ),
      ],
    );
  }

  Widget _buildMoodRow({
    String? imagePath,
    IconData? iconData,
    required String mood,
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
                  border: Border.all(color: AppColors.secondary, width: 2)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: imagePath != null
                    ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                )
                    : Icon(iconData, size: 20, color: AppColors.secondary),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.secondary, width: 2)),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(color: AppColors.secondary, width: 2)),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiCircle(String imagePath, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: AppColors.secondary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, err, stack) =>
              Icon(Icons.sentiment_neutral, size: 12, color: AppColors.secondary),
        ),
      ),
    );
  }

  void _navigateToJournalMoodPage(String mood) {
    context.push('/profile/mood_journal_list/$mood');
  }
}