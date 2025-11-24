import 'package:flutter/material.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:katahari/models/todo_model.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:katahari/pages/todo/create_todo_page.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String selectedStatus = "ongoing";
  final TodoService _service = TodoService();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;

  final GlobalKey _dropdownKey = GlobalKey();

  final List<Map<String, dynamic>> statusOptions = [
    {"label": "Completed", "value": "completed", "color": Color(0xFFD6F8C5)},
    {"label": "Ongoing", "value": "ongoing", "color": Color(0xFFFFEEAD)},
    {"label": "Missed", "value": "missed", "color": Color(0xFFFFB3B3)},
  ];

  @override
  void initState() {
    super.initState();
    // Jalankan markMissedTodos saat halaman dibuka
    _service.markMissedTodos();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: [
            // ====================
            // HEADER
            // ====================
            _buildHeader(),
            const SizedBox(height: 30),

            // ====================
            // HOW WAS YOUR DAY CARD
            // ====================
            const HowWasYourDayCard(),
            const SizedBox(height: 30),

            // ====================
            // TASK HEADER + DROPDOWN + PLUS BUTTON
            // ====================
            _buildTaskHeader(),
            const SizedBox(height: 20),

            // ====================
            // TODO LIST / EMPTY STATE
            // ====================
            StreamBuilder<List<Todo>>(
              stream: _service.getTodosByStatus(selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmpty(selectedStatus);
                }

                final todos = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTodoCard(todos[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ====================
  // HEADER
  // ====================
  Widget _buildHeader() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, User',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateFormat.format(now),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // ====================
  // TASK HEADER + DROPDOWN + PLUS BUTTON
  // ====================
  Widget _buildTaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Task',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Row(
          children: [
            _buildStatusDropdown(),
            const SizedBox(width: 8),
            // Tombol Plus
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateTodoPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF6BA6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    Color mainColor = statusOptions.firstWhere(
          (s) => s["value"] == selectedStatus,
      orElse: () => statusOptions[1],
    )["color"];

    String mainLabel = statusOptions.firstWhere(
          (s) => s["value"] == selectedStatus,
      orElse: () => statusOptions[1],
    )["label"];

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _dropdownKey,
        onTap: toggleDropdown,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }

  void toggleDropdown() {
    if (isDropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _buildOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => isDropdownOpen = true);
  }

  void closeDropdown() {
    _overlayEntry?.remove();
    setState(() => isDropdownOpen = false);
  }

  OverlayEntry _buildOverlayEntry() {
    RenderBox renderBox =
    _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double width = renderBox.size.width;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + renderBox.size.height + 6,
          width: width,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: statusOptions.map((status) {
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedStatus = status["value"]);
                    closeDropdown();
                  },
                  child: Container(
                    width: width,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: status["color"],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        status["label"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ====================
  // EMPTY STATE
  // ====================
  Widget _buildEmpty(String status) {
    String assetImage;
    String message;

    switch (status.toLowerCase()) {
      case 'ongoing':
        assetImage = "assets/empty_ongoing.png";
        message = "No tasks to accomplish";
        break;
      case 'completed':
        assetImage = "assets/empty_completed.png";
        message = "No task completed.";
        break;
      case 'missed':
        assetImage = "assets/empty_missed.png";
        message = "No missed tasks.";
        break;
      default:
        assetImage = "assets/empty_ongoing.png";
        message = "No data";
    }

    return Center(
      child: Column(
        children: [
          Image.asset(
            assetImage,
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // ====================
  // TODO CARD
  // ====================
  Widget _buildTodoCard(Todo todo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1), // hard black border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ICON LABEL BOX
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _getLabelColor(todo.label).withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(
              _getLabelIcon(todo.label),
              color: _getLabelColor(todo.label),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // TITLE + LABEL + TIME
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  todo.deadlineDate != null
                      ? "${todo.label} | ${DateFormat('EEE, d MMM yyyy HH.mm').format(todo.deadlineDate!)}"
                      : "${todo.label} | No deadline",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontFamily: 'Poppins',
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 10),

          // CIRCLE TOGGLE (COMPLETED STYLE)
          GestureDetector(
            onTap: () async {
              if (todo.status == 'ongoing') {
                await _service.updateStatus(todo.id, 'completed');
              } else if (todo.status == 'completed') {
                await _service.updateStatus(todo.id, 'ongoing');
              }
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                color:
                todo.status == 'completed' ? Colors.black : Colors.white,
              ),
              child: todo.status == 'completed'
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }


  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'study':
        return Icons.school_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'study':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColorForCard(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}