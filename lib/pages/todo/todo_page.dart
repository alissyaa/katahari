import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:katahari/models/todo_model.dart';
import 'package:katahari/components/journal/how_was_your_day_card.dart';
import 'package:katahari/components/todo/empty_state.dart';
import 'package:intl/intl.dart';
import 'package:katahari/constant/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:katahari/components/all/header_widget.dart';
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
            HeaderWidget(
              userName: loggedInUser,
              date: formattedDate,
            ),
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
                  return EmptyStateWidget(status: selectedStatus);
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

  Widget _buildTodoCard(Todo todo) {
    return GestureDetector(
      onTap: () => _showTodoDetailDialog(todo),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.secondary, width: 2),
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
                  border: Border.all(color: AppColors.secondary, width: 2),
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
                      width: 2,
                    ),
                    color: todo.status == 'completed'
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  child: todo.status == 'completed'
                      ? const Icon(Icons.check, color: AppColors.primary, size: 18)
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
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(
              color: AppColors.secondary,
              width: 2.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= ROW STATUS & DATE =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColors.secondary, width: 2),
                      ),
                      child: Text(
                        todo.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColors.secondary, width: 2),
                      ),
                      child: Text(
                        todo.deadlineDate != null
                            ? DateFormat('dd MMM yyyy HH:mm').format(todo.deadlineDate!)
                            : 'No deadline',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

// ================= TITLE + ICON =================
                Column(
                  children: [
                    Center(
                      child: Text(
                        todo.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

// ================= DESCRIPTION =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.secondary, width: 2),
                    ),
                  ),
                  child: Text(
                    todo.description.isNotEmpty
                        ? todo.description
                        : 'No description',
                    textAlign: TextAlign.center,    // <-- CENTER
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.abu,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ================= BUTTONS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // EDIT BUTTON
                    SizedBox(
                      width: 120,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: AppColors.secondary, width: 2),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          context.push(AppRoutes.editTodo, extra: todo);
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // DELETE BUTTON
                    SizedBox(
                      width: 120,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.merah,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: AppColors.secondary, width: 2),
                          ),
                        ),
                        onPressed: () async {
                          await _service.deleteTodo(todo.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
