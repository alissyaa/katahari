import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';

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
              _buildProfileCard(),
              const SizedBox(height: 28),
              _buildMoodTrackerTitle(),
              const SizedBox(height: 20),

              _buildMoodRow(
                iconData: Icons.sentiment_very_satisfied,
                backgroundColor: AppColors.screen1,
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_neutral,
                backgroundColor: AppColors.screen2,
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_very_dissatisfied,
                backgroundColor: AppColors.merah,
                count: 0,
              ),
              _buildMoodRow(
                iconData: Icons.sentiment_dissatisfied,
                backgroundColor: AppColors.button,
                count: 0,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Builders ---

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
          onTap: () {},
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
        color: AppColors.screen2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Column(
        children: [
          // Top white bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                    Icon(Icons.auto_awesome,
                        size: 20, color: AppColors.secondary),
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

                // Emoji circles
                Row(
                  children: [
                    _buildEmojiCircle(Icons.sentiment_very_satisfied,
                        AppColors.screen1),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_neutral, AppColors.screen2),
                    const SizedBox(width: 6),
                    _buildEmojiCircle(
                        Icons.sentiment_very_dissatisfied, AppColors.merah),
                  ],
                ),
              ],
            ),
          ),

          // Content below header
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
                    border: Border.all(
                        color: AppColors.secondary, width: 1.5),
                  ),
                  child: Icon(Icons.add_a_photo,
                      size: 32, color: AppColors.secondary),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name\n-",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Text("Birthday\n-",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Text("MBTI\n-",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
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
        "User's Mood Tracker",
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
          // Emoji circle
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

          // Count bubble
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

          // Arrow button
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child:
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
