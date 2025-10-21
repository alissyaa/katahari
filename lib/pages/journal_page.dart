import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class journalpage extends StatefulWidget {
  const journalpage({super.key});

  @override
  State<journalpage> createState() => _journalpageState();
}

class _journalpageState extends State<journalpage> {

  final user=FirebaseAuth.instance.currentUser!;

  signout() async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Homepage"),),
      body: Center(
        child: Text('${user!.email}'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (()=>signout()),
          child: Icon(Icons.login_rounded),
      ),
    );
  }
}
