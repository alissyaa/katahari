import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:katahari/components/journal/journal_grid.dart';
import 'package:katahari/constant/app_colors.dart';
import '../components/journal/dropdown.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _searchController = TextEditingController();
  
  // --- State untuk filter ---
  String _searchQuery = '';
  String? _selectedMoodFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get loggedInUser {
    return user.displayName ?? user.email?.split('@')[0] ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.primary,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.button,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 3),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, size: 40, color: AppColors.secondary),
            onPressed: () {
              context.push('/add_journal');
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 20),
            Text(
              'Hello, ${displayName[0].toUpperCase()}${displayName.substring(1)}',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.abumuda,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            const HowWasYourDayCard(),
            const SizedBox(height: 30),
            _buildJournalHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            // --- Mengirim state filter ke JournalGrid ---
            JournalGrid(
              searchQuery: _searchQuery,
              moodFilter: _selectedMoodFilter,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Journal',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        MoodDropdown(
          onSelected: (value) {
            setState(() {
              // --- PERBAIKAN DI SINI ---
              // Jika memilih 'Filter' atau 'All', hapus filternya (set ke null)
              _selectedMoodFilter = (value == 'Filter' || value == 'All') ? null : value.toLowerCase();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: GoogleFonts.poppins(),
        prefixIcon: const Icon(Icons.search, size: 28),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2.5),
        ),
      ),
    );
  }
}
