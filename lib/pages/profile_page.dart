import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';
import 'package:katahari/pages/edit_profile_page.dart';
import 'package:katahari/pages/journal_mood_page.dart';
import 'package:katahari/pages/settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "-";
  String _birthday = "-";
  String _mbti = "-";
  Color _cardColor = AppColors.kream;
  Color _headerColor = AppColors.primary;

  final User? user = FirebaseAuth.instance.currentUser;
  late String userName;
  final String formattedDate =
  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            _name = userDoc.get('name') ?? "-";
            _birthday = userDoc.get('birthday') ?? "-";
            _mbti = userDoc.get('mbti') ?? "-";
            userName = _name;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Stream<QuerySnapshot> _getJournalsStream() {
    if (user == null) {
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .collection('Journals')
        .snapshots();
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfilePage(
              currentName: _name,
              currentBirthday: _birthday,
              currentMbti: _mbti,
              currentCardColor: _cardColor,
              currentHeaderColor: _headerColor,
            ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _name = result['name'];
        _birthday = result['birthday'];
        _mbti = result['mbti'];
        _cardColor = result['cardColor'];
        _headerColor = result['headerColor'];
        userName = _name;
      });
    }
  }

  void _navigateToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _navigateToJournalMoodPage(String mood) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalMoodPage(mood: mood),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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
              GestureDetector(
                onTap: _navigateToEditPage,
                child: _buildProfileCard(),
              ),
              const SizedBox(height: 28),
              _buildMoodTrackerTitle(),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _getJournalsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildAllMoodRows(0, 0, 0, 0);
                  }

                  int happyCount = 0;
                  int neutralCount = 0;
                  int sadCount = 0;
                  int angryCount = 0;

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final mood = data['mood'] as String?;
                    switch (mood) {
                      case 'happy':
                        happyCount++;
                        break;
                      case 'flat':
                        neutralCount++;
                        break;
                      case 'sad':
                        sadCount++;
                        break;
                      case 'angry':
                        angryCount++;
                        break;
                    }
                  }

                  return _buildAllMoodRows(
                      happyCount, neutralCount, sadCount, angryCount);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllMoodRows(int happy, int neutral, int sad, int angry) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('happy'),
          child: _buildMoodRow(
            iconData: Icons.sentiment_very_satisfied,
            backgroundColor: AppColors.screen1,
            count: happy,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('flat'),
          child: _buildMoodRow(
            iconData: Icons.sentiment_neutral,
            backgroundColor: AppColors.screen2,
            count: neutral,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('sad'),
          child: _buildMoodRow(
            iconData: Icons.sentiment_very_dissatisfied,
            backgroundColor: AppColors.button,
            count: sad,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToJournalMoodPage('angry'),
          child: _buildMoodRow(
            iconData: Icons.sentiment_dissatisfied,
            backgroundColor: AppColors.merah,
            count: angry,
          ),
        ),
      ],
    );
  }

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
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.abumuda,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: _navigateToSettingsPage,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            Icons.settings_outlined,
            size: 30,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.secondary, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'katahari.',
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
                    _buildEmojiCircle(
                        Icons.sentiment_very_satisfied, AppColors.screen1),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_neutral, AppColors.screen2),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_very_dissatisfied, AppColors.button),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_dissatisfied, AppColors.merah),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary, width: 1.5),
                  ),
                  child: Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name\n$_name",
                      style: GoogleFonts.poppins(
                          height: 1.5, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Birthday\n$_birthday",
                      style: GoogleFonts.poppins(
                          height: 1.5, color: AppColors.secondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "MBTI\n$_mbti",
                      style: GoogleFonts.poppins(
                          height: 1.5, color: AppColors.secondary),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
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
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Icon(icon, color: AppColors.secondary, size: 14),
    );
  }

  Widget _buildMoodTrackerTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Text(
        "$userName's Mood Tracker",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildMoodRow({
    required IconData iconData,
    required Color backgroundColor,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: Icon(iconData, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
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
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}