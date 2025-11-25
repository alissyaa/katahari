import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:katahari/constant/app_colors.dart';

class Sticker {
  final String assetPath;
  Offset position;
  final double size;

  Sticker({
    required this.assetPath,
    required this.position,
    this.size = 100.0,
  });

  Map<String, dynamic> toJson() => {
    'assetPath': assetPath,
    'dx': position.dx,
    'dy': position.dy,
    'size': size,
  };

  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
    assetPath: json['assetPath'],
    position: Offset(json['dx'] ?? 0.0, json['dy'] ?? 0.0),
    size: (json['size'] as num?)?.toDouble() ?? 100.0,
  );
}

class AddJournalPage extends StatefulWidget {
  final String? journalId;
  const AddJournalPage({super.key, this.journalId});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedImages = [];
  final List<String> _existingImageUrls = [];
  final List<Sticker> _activeStickers = [];
  bool _isLoading = true;
  double _fontSize = 16.0;
  Color _textColor = Colors.black87;
  String _selectedMood = 'happy';

  final List<double> _fontSizes = [12, 14, 16, 18, 20, 24, 28];
  final List<Color> _textColors = [
    Colors.black87, const Color(0xFFD32F2F), const Color(0xFF303F9F),
    const Color(0xFF388E3C), const Color(0xFFF57C00), const Color(0xFF7B1FA2),
  ];

  final Map<String, String> _moodAssets = {
    'happy': 'assets/mood_happy.png',
    'flat': 'assets/mood_flat.png',
    'sad': 'assets/mood_sad.png',
    'angry': 'assets/mood_angry.png',
  };

  bool get _isEditMode => widget.journalId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadJournalData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadJournalData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found");

      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('journals').doc(widget.journalId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _fontSize = (data['fontSize'] as num?)?.toDouble() ?? 16.0;
          _textColor = Color(data['textColor'] as int? ?? Colors.black87.value);
          _selectedMood = data['mood'] ?? 'happy';
          _existingImageUrls.addAll(List<String>.from(data['imageUrls'] ?? []));
          final stickersData = List<Map<String, dynamic>>.from(data['stickers'] ?? []);
          _activeStickers.addAll(stickersData.map((d) => Sticker.fromJson(d)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final maxImages = 4 - _existingImageUrls.length - _selectedImages.length;
    if (maxImages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimal 4 gambar.')));
      return;
    }
    final List<XFile> images = await _picker.pickMultiImage(limit: maxImages);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<List<String>> _uploadImages(String userId, String journalId) async {
    if (_selectedImages.isEmpty) return [];
    List<String> newImageUrls = [];
    for (var imageFile in _selectedImages) {
      final fileName = path.basename(imageFile.path);
      final destination = 'users/$userId/journals/$journalId/$fileName';
      try {
        final ref = FirebaseStorage.instance.ref(destination);
        await ref.putFile(File(imageFile.path));
        newImageUrls.add(await ref.getDownloadURL());
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return newImageUrls;
  }

  Future<void> _saveJournalEntry() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong.')));
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final docRef = _isEditMode
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).collection('journals').doc(widget.journalId)
          : FirebaseFirestore.instance.collection('users').doc(user.uid).collection('journals').doc();

      final newImageUrls = await _uploadImages(user.uid, docRef.id);
      final allImageUrls = _existingImageUrls + newImageUrls;

      final stickersData = _activeStickers.map((s) => s.toJson()).toList();

      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'fontSize': _fontSize,
        'textColor': _textColor.value,
        'imageUrls': allImageUrls,
        'stickers': stickersData,
        'mood': _selectedMood,
      };

      if (_isEditMode) {
        await docRef.update(data);
      } else {
        await docRef.set(data);
      }

      if (mounted) {
        Navigator.of(context).pop();
        context.pop();
      }
    } catch (e) {
      print("Error saving journal entry: $e");
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('E, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        centerTitle: true,
        title: Text('Journal', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [IconButton(icon: const Icon(Icons.check, color: Colors.black, size: 28), onPressed: _saveJournalEntry)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    GestureDetector(
                      onTap: _showMoodPicker,
                      child: Image.asset(
                        _moodAssets[_selectedMood] ?? 'assets/mood_happy.png',
                        width: 36,
                        height: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildImageGrid(),
                if (_selectedImages.isNotEmpty || _existingImageUrls.isNotEmpty) const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: _textColor),
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(hintText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  style: GoogleFonts.poppins(fontSize: _fontSize, color: _textColor, height: 1.6),
                  maxLines: null,
                  decoration: const InputDecoration.collapsed(hintText: 'Start writing your story...'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTag(Icons.location_on_outlined, 'Location Here'),
                    const SizedBox(width: 10),
                    _buildTag(Icons.music_note_outlined, 'Song Here'),
                  ],
                ),
              ],
            ),
          ),
          ..._activeStickers.map((sticker) {
            return Positioned(
              left: sticker.position.dx,
              top: sticker.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    sticker.position += details.delta;
                  });
                },
                child: Image.asset(
                  sticker.assetPath,
                  width: sticker.size,
                  height: sticker.size,
                ),
              ),
            );
          }),
          Positioned(bottom: 30, left: 20, right: 20, child: _buildEditingToolbar()),
        ],
      ),
    );
  }

  void _showStickerPicker() {
    final List<String> stickerAssets = [
      'assets/sticker1.png',
      'assets/sticker2.png',
      'assets/sticker3.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: stickerAssets.map((asset) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeStickers.add(
                      Sticker(
                        assetPath: asset,
                        position: Offset(
                          MediaQuery.of(context).size.width / 2 - 50,
                          MediaQuery.of(context).size.height / 3 - 50,
                        ),
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                },
                child: Image.asset(asset, width: 80, height: 80),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
            child: Text('T', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(icon: Icon(Icons.circle, color: _textColor, size: 28), onPressed: _showColorPicker),
          TextButton(
            onPressed: _showFontSizePicker,
            child: Row(children: [Text('${_fontSize.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)), const Icon(Icons.arrow_drop_down, color: Colors.white)]),
          ),
          IconButton(icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 26), onPressed: _pickImages),
          IconButton(icon: const Icon(Icons.mood_outlined, color: Colors.white, size: 26), onPressed: _showStickerPicker),
          IconButton(icon: const Icon(Icons.layers_outlined, color: Colors.white, size: 26), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final allImageWidgets = <Widget>[
      ..._existingImageUrls.map((url) => _buildGridItem(Image.network(url, fit: BoxFit.cover), () => setState(() => _existingImageUrls.remove(url)))),
      ..._selectedImages.map((file) => _buildGridItem(Image.file(File(file.path), fit: BoxFit.cover), () => setState(() => _selectedImages.remove(file)))),
    ];

    if (allImageWidgets.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: allImageWidgets.length > 1 ? 2 : 1,
        crossAxisSpacing: 8, mainAxisSpacing: 8,
        childAspectRatio: allImageWidgets.length == 3 ? 0.67 : 1,
      ),
      itemCount: allImageWidgets.length,
      itemBuilder: (context, index) => allImageWidgets[index],
    );
  }

  Widget _buildGridItem(Widget image, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(aspectRatio: 1, child: image),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _showFontSizePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: _fontSizes.map((size) => ListTile(title: Text('Font Size ${size.toInt()}', textAlign: TextAlign.center), onTap: () => setState(() { _fontSize = size; Navigator.of(context).pop(); }))).toList(),
        ),
      ),
    );
  }

  // --- FUNGSI YANG HILANG DIKEMBALIKAN DI SINI ---
  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _moodAssets.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = entry.key;
                  });
                  Navigator.of(context).pop();
                },
                child: Image.asset(entry.value, width: 60, height: 60),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 16.0,
            children: _textColors.map((color) => GestureDetector(onTap: () => setState(() { _textColor = color; Navigator.of(context).pop(); }), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))))).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, size: 18, color: Colors.grey[700]), const SizedBox(width: 6), Text(label, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500))]),
    );
  }
}