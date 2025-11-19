import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:katahari/components/journal/journal_grid.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final user = FirebaseAuth.instance.currentUser!;

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return const Color(0xFFD7F0C5); // Light Green
      case 'Flat':
        return const Color(0xFFFFF3A7); // Light Yellow
      case 'Angry':
        return const Color(0xFFFFC6C6); // Light Red
      case 'Sad':
        return const Color(0xFFB9D7F7); // Light Blue
      case 'Filter':
        return Colors.grey[300]!;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        child: FaIcon(FontAwesomeIcons.plus),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 20),
            // Header
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
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // "How Did Your Day Go?" Card
            const HowWasYourDayCard(),
            const SizedBox(height: 30),

            // Journal Section Header
            _buildJournalHeader(),
            const SizedBox(height: 20),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            const JournalGrid(),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: DropdownButton<String>(
            value: 'Filter',
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),
            isDense: true,
            borderRadius: BorderRadius.circular(20),
            items: <String>['Filter', 'Happy', 'Flat', 'Angry', 'Sad']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getMoodColor(value),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {},
            selectedItemBuilder: (BuildContext context) {
              return <String>['Filter', 'Happy', 'Flat', 'Angry', 'Sad']
                  .map<Widget>((String item) {
                return Center(
                  child: Text(
                    'Filter', // Always show 'Filter' text for the selected item button
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: GoogleFonts.poppins(),
        prefixIcon: const Icon(Icons.search, size: 28),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
    );
  }
}
