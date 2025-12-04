import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:katahari/models/todo_model.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/routes.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoService _service = TodoService();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;

  final GlobalKey _dropdownKey = GlobalKey();
  String selectedStatus = "ongoing";

  final List<Map<String, dynamic>> statusOptions = [
    {"label": "Completed", "value": "completed", "color": AppColors.screen1},
    {"label": "Ongoing", "value": "ongoing", "color": AppColors.screen2},
    {"label": "Missed", "value": "missed", "color": AppColors.merah},
  ];

  final List<Map<String, dynamic>> labelOptions = [
    {"label": "Work", "value": "work", "icon": Icons.work_outline, "color": AppColors.button},
    {"label": "Personal", "value": "personal", "icon": Icons.person_outline, "color": Colors.purple},
    {"label": "Shopping", "value": "shopping", "icon": Icons.shopping_cart_outlined, "color": AppColors.merah},
    {"label": "Study", "value": "study", "icon": Icons.school_outlined, "color": AppColors.screen2},
  ];

  User get user => FirebaseAuth.instance.currentUser!;

  String get loggedInUser {
    return user.displayName ?? user.email?.split('@')[0] ?? 'User';
  }

  @override
  void initState() {
    super.initState();
    _service.markMissedTodos();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          children: [
            _buildHeader(loggedInUser, formattedDate),
            const SizedBox(height: 30),
            const HowWasYourDayCard(),
            const SizedBox(height: 30),
            _buildTaskHeader(),
            const SizedBox(height: 20),
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

  // ================= HEADER =================

  Widget _buildHeader(String userName, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $userName',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.abu,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // ================= TASK HEADER + ADD BUTTON =================

  Widget _buildTaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Task',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Row(
          children: [
            _buildStatusDropdown(),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.addTodos);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= DROPDOWN STATUS =================

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
            border: Border.all(color: AppColors.secondary, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mainLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: AppColors.secondary,
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
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        status["label"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
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

  // ================= EMPTY STATE =================

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
              color: AppColors.abumuda,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // ================= TODO CARD (BISA DI-TAP) =================

  Widget _buildTodoCard(Todo todo) {
    return GestureDetector(
      onTap: () {
        _showTodoDetailDialog(todo);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.secondary, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                ),
                child: Icon(
                  _getLabelIcon(todo.label),
                  color: _getLabelColor(todo.label),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: AppColors.secondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      todo.deadlineDate != null
                          ? "${todo.label} | ${DateFormat('dd MMM yyyy HH:mm').format(todo.deadlineDate!)}"
                          : "${todo.label} | No deadline",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontFamily: 'Poppins',
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  // supaya tidak ikut trigger onTap card, kita stop event bubble pakai gesture ini
                  if (todo.status == 'ongoing') {
                    await _service.updateStatus(todo.id, 'completed');
                  } else if (todo.status == 'completed') {
                    await _service.updateStatus(todo.id, 'ongoing');
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                    color: todo.status == 'completed'
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  child: todo.status == 'completed'
                      ? const Icon(Icons.check,
                      color: AppColors.primary, size: 18)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= POPUP DETAIL TODO =================

  Future<void> _showTodoDetailDialog(Todo todo) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: AppColors.secondary,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TOP: status + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        todo.status, // <-- ganti repeatType jadi status
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        todo.deadlineDate != null
                            ? DateFormat('dd MMM yyyy HH:mm')
                            .format(todo.deadlineDate!)
                            : 'No deadline',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // TITLE + ICON
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all( // <-- Border.all, bukan BorderSide
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getLabelIcon(todo.label),
                        color: _getLabelColor(todo.label),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // DESCRIPTION
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.secondary,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    todo.description.isNotEmpty ? todo.description : 'No description',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // EDIT
                    SizedBox(
                      width: 110,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.secondary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push(
                            AppRoutes.editTodo,
                            extra: todo,
                          );
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    // DELETE
                    SizedBox(
                      width: 110,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.merah, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () async {
                          await _service.deleteTodo(todo.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.merah,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        return AppColors.button;
      case 'personal':
        return Colors.purple;
      case 'shopping':
        return AppColors.merah;
      case 'study':
        return AppColors.screen2;
      default:
        return AppColors.abumuda;
    }
  }
}
