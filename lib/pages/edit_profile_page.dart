import 'dart:io'; // Diperlukan untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Diperlukan untuk User ID
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Diperlukan untuk memilih gambar
import 'package:katahari/constant/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Diperlukan untuk Supabase
import 'package:path/path.dart' as path;

import '../config/routes.dart'; // Diperlukan untuk nama file

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBirthday;
  final String currentMbti;
  final Color currentCardColor;
  final Color currentHeaderColor;
  final String? currentImageUrl; // <-- Tambahkan ini

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentBirthday,
    required this.currentMbti,
    required this.currentCardColor,
    required this.currentHeaderColor,
    this.currentImageUrl, // <-- Tambahkan ini
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _mbtiController;

  late Color _selectedBodyColor;
  late Color _selectedHeaderColor;

  // --- STATE BARU UNTUK GAMBAR ---
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImageFile;
  String? _existingImageUrl;

  final List<Color> headerColorOptions = [
    AppColors.primary,
    AppColors.merah,
    AppColors.screen1,
    AppColors.screen2,
    AppColors.button,
  ];

  Color getBodyColorForHeader(Color headerColor) {
    if (headerColor == AppColors.button) return AppColors.kream;
    if (headerColor == AppColors.screen1) return AppColors.kream;
    return AppColors.kream;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.currentName == "-" ? "" : widget.currentName);
    _birthdayController = TextEditingController(
        text: widget.currentBirthday == "-" ? "" : widget.currentBirthday);
    _mbtiController = TextEditingController(
        text: widget.currentMbti == "-" ? "" : widget.currentMbti);
    _selectedBodyColor = widget.currentCardColor;
    _selectedHeaderColor = widget.currentHeaderColor;
    _existingImageUrl = widget.currentImageUrl; // <-- Inisialisasi URL gambar
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _mbtiController.dispose();
    super.dispose();
  }

  // --- FUNGSI BARU UNTUK MEMILIH GAMBAR ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (_selectedImageFile == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return null;
    }

    try {
      final file = File(_selectedImageFile!.path);
      final bytes = await file.readAsBytes();
      final fileExtension = path.extension(_selectedImageFile!.path).toLowerCase();
      final filePath = '${user.uid}/profile$fileExtension'; // path di dalam bucket

      final supabase = Supabase.instance.client;

      // Upload file ke bucket public 'avatars'
      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: fileExtension == '.png' ? 'image/png' : 'image/jpeg',
        ),
      );

      // Ambil public URL langsung (String)
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal unggah foto: $e")),
      );
      return null;
    }
  }


  void _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? newImageUrl = await _uploadProfilePicture();

      final updatedData = {
        'name': _nameController.text.isEmpty ? "-" : _nameController.text,
        'birthday': _birthdayController.text.isEmpty ? "-" : _birthdayController.text,
        'mbti': _mbtiController.text.isEmpty ? "-" : _mbtiController.text,
        'cardColor': _selectedBodyColor.value,
        'headerColor': _selectedHeaderColor.value,
        'imageUrl': newImageUrl ?? _existingImageUrl,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'profile': updatedData}, SetOptions(merge: true));

      if (!mounted) return;

      // --- PERBAIKAN UTAMA DI SINI ---
      // 1. Tutup dialog loading dulu
      Navigator.of(context).pop();
      // 2. Tutup halaman edit, maka akan otomatis kembali ke halaman profil
      GoRouter.of(context).go(AppRoutes.profile);

    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Tutup loading jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan profil: $e")),
      );
    }
  }


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
              _buildAppBar(),
              const SizedBox(height: 12),
              _buildPreviewCard(),
              const SizedBox(height: 32),
              _buildColorSelector(),
              const SizedBox(height: 24),
              _buildTextField(
                  label: "Name",
                  controller: _nameController,
                  hint: "Enter name"),
              _buildTextField(
                  label: "Birthday",
                  controller: _birthdayController,
                  hint: "Enter birthday"),
              _buildTextField(
                  label: "MBTI",
                  controller: _mbtiController,
                  hint: "Enter MBTI"),
              const SizedBox(height: 16),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Icon(Icons.arrow_back_ios_new,
                size: 24, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Text(
            "Edit ID Card",
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: _selectedBodyColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedHeaderColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(color: AppColors.secondary, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.auto_awesome,
                      size: 20, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text('katahari.',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.secondary)),
                ]),
                Row(children: [
                  _buildEmojiCircle(
                      Icons.sentiment_very_satisfied, AppColors.screen1),
                  const SizedBox(width: 6),
                  _buildEmojiCircle(Icons.sentiment_neutral, AppColors.screen2),
                  const SizedBox(width: 6),
                  _buildEmojiCircle(
                      Icons.sentiment_very_dissatisfied, AppColors.merah),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // --- PERUBAHAN UI GAMBAR PROFIL ---
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border:
                        Border.all(color: AppColors.secondary, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildProfileImage(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Name\n${_nameController.text.isEmpty ? '-' : _nameController.text}",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Text(
                        "Birthday\n${_birthdayController.text.isEmpty ? '-' : _birthdayController.text}",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Text(
                        "MBTI\n${_mbtiController.text.isEmpty ? '-' : _mbtiController.text}",
                        style: GoogleFonts.poppins(
                            height: 1.5, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU UNTUK MENAMPILKAN GAMBAR ---
  // --- WIDGET BARU UNTUK MENAMPILKAN GAMBAR ---
  Widget _buildProfileImage() {
    // 1. Jika ada gambar BARU yang dipilih, tampilkan itu.
    if (_selectedImageFile != null) {
      return Image.file(
        File(_selectedImageFile!.path),
        // --- PERBAIKAN DI SINI: MEMAKSA WIDGET UNTUK UPDATE ---
        key: UniqueKey(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    // 2. Jika tidak ada gambar baru, tapi ada URL gambar LAMA, tampilkan itu.
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) =>
        progress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) =>
            Icon(Icons.add_a_photo, size: 32, color: AppColors.secondary),
      );
    }
    // 3. Jika tidak ada keduanya, tampilkan ikon tambah.
    return Icon(Icons.add_a_photo, size: 32, color: AppColors.secondary);
  }


  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.secondary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: headerColorOptions.map((color) {
            bool isSelected = _selectedHeaderColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHeaderColor = color;
                  _selectedBodyColor = getBodyColorForHeader(color);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: AppColors.kream, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
        required TextEditingController controller,
        required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.secondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: (value) => setState(() {}),
            style: TextStyle(color: AppColors.secondary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.abumuda),
              filled: true,
              fillColor: AppColors.primary,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                BorderSide(color: AppColors.secondary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                BorderSide(color: AppColors.secondary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.button, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: AppColors.secondary, width: 1.5),
          ),
          elevation: 0,
        ),
        child: Text(
          "Save",
          style: GoogleFonts.poppins(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
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
          border: Border.all(width: 1.5, color: AppColors.secondary)),
      child: Icon(icon, color: AppColors.secondary, size: 14),
    );
  }
}