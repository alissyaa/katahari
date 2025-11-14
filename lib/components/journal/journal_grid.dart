import 'package:flutter/material.dart';
import 'package:katahari/components/journal/journal_card.dart';

class JournalGrid extends StatelessWidget {
  const JournalGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // This data should ideally be fetched from a state management solution or passed down.
    final List<Map<String, dynamic>> journalEntries = [
      {
        'title': 'Aku dapat ghost w...',
        'date': 'Tue, 12 September 2025',
        'mood': 'happy',
        'image': 'https://i.pinimg.com/564x/8f/52/64/8f52642d9526a7b3737b019488e5a2a2.jpg'
      },
      {
        'title': 'Trip gone wrong',
        'date': 'Tue, 12 September 2025',
        'mood': 'angry',
        'image': 'https://i.pinimg.com/564x/4e/4a/0c/4e4a0c5c6b3b2a5d214af6b1e6255c26.jpg'
      },
      {
        'title': 'Kebanyakan kelas ganti',
        'date': 'Tue, 11 September 2025',
        'mood': 'neutral',
        'image': null
      },
      {
        'title': 'Aku dapat ghost s...',
        'date': 'Tue, 12 September 2025',
        'mood': 'happy',
        'image': 'https://i.pinimg.com/564x/8f/52/64/8f52642d9526a7b3737b019488e5a2a2.jpg'
      },
      {
        'title': 'Meet up bestiee!!!',
        'date': 'Tue, 10 September 2025',
        'mood': 'happy',
        'image': 'https://i.pinimg.com/564x/ac/5c/45/ac5c453549926868a12515b671758655.jpg'
      },
    ];

    // The total number of items in the grid is the number of journal entries plus the 'add' card.
    const int addCardPosition = 3;
    final int totalItems = journalEntries.length + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalItems,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {

        // Adjust the index to fetch from the journalEntries list.
        final entryIndex = index > addCardPosition ? index - 1 : index;

        final entry = journalEntries[entryIndex];
        return JournalCard(entry: entry);
      },
    );
  }
}
