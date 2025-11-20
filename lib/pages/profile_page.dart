import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Profile Page",
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
