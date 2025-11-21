import 'dart:io';
//bismillah semoga ketmu
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:katahari/pages/todo/create_todo_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final user = FirebaseAuth.instance.currentUser!;

  late String displayName;
  late String _selectedStatus;

  final List<Map<String, String>> _todos = [];

  final String _assetCompleted = 'assets/empty_completed.png';
  final String _assetMissed = 'assets/empty_missed.png';
  final String _assetOngoing = 'assets/empty_ongoing.png';

  final String _fallbackLocalImage =
      '/mnt/data/c0d2fb34-9e50-48c6-ac53-b374f02af002.png';

  @override
  void initState() {
    super.initState();
    displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    _selectedStatus = 'Ongoing';
  }

  // Colors for each status
  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFFD7F0C5);
      case 'Missed':
        return const Color(0xFFFFC6C6);
      case 'Ongoing':
      default:
        return const Color(0xFFFFF3A7);
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'Completed':
        return 'No task completed.';
      case 'Missed':
        return 'No missed tasks.';
      case 'Ongoing':
      default:
        return 'No tasks to accomplish.';
    }
  }

  String _assetForStatus(String status) {
    switch (status) {
      case 'Completed':
        return _assetCompleted;
      case 'Missed':
        return _assetMissed;
      case 'Ongoing':
      default:
        return _assetOngoing;
    }
  }

  Widget _buildStatusImage(String status) {
    final String assetPath = _assetForStatus(status);

    return Image.asset(
      assetPath,
      width: 160,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final File fallbackFile = File(_fallbackLocalImage);
        return Image.file(
          fallbackFile,
          width: 160,
          height: 160,
          fit: BoxFit.contain,
          errorBuilder: (context, err, st) {
            return FaIcon(
              FontAwesomeIcons.listCheck,
              size: 60,
              color: Colors.grey[600],
            );
          },
        );
      },
    );
  }

  List<Map<String, String>> get _filteredTodos {
    return _todos.where((t) => t['status'] == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          children: [
            const SizedBox(height: 20),

            // Greeting
            Text(
              'Hello, ${displayName[0].toUpperCase()}${displayName.substring(1)}',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 18),
            const HowWasYourDayCard(),
            const SizedBox(height: 24),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // STATUS DROPDOWN
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                  decoration: BoxDecoration(
                    color: _statusColor(_selectedStatus),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      isDense: true,
                      borderRadius: BorderRadius.circular(20),
                      items: <String>['Completed', 'Missed', 'Ongoing']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _statusColor(value),
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
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      selectedItemBuilder: (context) {
                        return ['Completed', 'Missed', 'Ongoing']
                            .map((value) {
                          return Center(
                            child: Text(
                              value,
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- EMPTY VIEW ---
            if (_filteredTodos.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    _buildStatusImage(_selectedStatus),
                    const SizedBox(height: 18),

                    Text(
                      _statusDescription(_selectedStatus),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateTodoPage(),
                          ),
                        );

                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            _todos.add(result);
                          });
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]

            // --- LIST VIEW ---
            else ...[
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredTodos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final todo = _filteredTodos[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo['title'] ?? 'Untitled',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                    todo['status'] ?? _selectedStatus),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                todo['status'] ?? _selectedStatus,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              _todos.remove(todo);
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
