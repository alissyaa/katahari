import 'package:flutter/material.dart';

class MoodDropdown extends StatefulWidget {
  final Function(String) onSelected;
  final String? selectedValue; // <-- Parameter untuk menerima nilai terpilih
  const MoodDropdown({super.key, required this.onSelected, this.selectedValue});

  @override
  State<MoodDropdown> createState() => _MoodDropdownState();
}

class _MoodDropdownState extends State<MoodDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool isOpen = false;
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedValue ?? "All";
  }

  // --- PERBAIKAN DI SINI ---
  // Memastikan widget diperbarui saat ada perubahan dari luar
  @override
  void didUpdateWidget(MoodDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        selected = widget.selectedValue ?? "All";
      });
    }
  }

  final List<Map<String, dynamic>> moods = [
    {"label": "All", "color": Color(0xFFE0E0E0)},
    {"label": "Happy", "color": Color(0xFFD6F8C5)},
    {"label": "Sad", "color": Color(0xFFBCD9FF)},
    {"label": "Flat", "color": Color(0xFFFFEEAD)},
    {"label": "Angry", "color": Color(0xFFFFB3B3)},
  ];

  void toggleDropdown() {
    if (isOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _buildOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => isOpen = true);
  }

  void closeDropdown() {
    _overlayEntry?.remove();
    setState(() => isOpen = false);
  }

  OverlayEntry _buildOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: moods.map((m) {
                return GestureDetector(
                  onTap: () {
                    setState(() => selected = m["label"]);
                    widget.onSelected(m["label"]);
                    closeDropdown();
                  },
                  child: Container(
                    width: width,
                    margin: const EdgeInsets.only(bottom: 1),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: m["color"],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        m["label"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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

  @override
  Widget build(BuildContext context) {
    Color mainColor = moods.firstWhere(
          (m) => m["label"] == selected,
      orElse: () => moods[0],
    )["color"];

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
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
                selected,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
