import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      appBar: AppBar(
        title: Text("Hello" '${user!.email}'),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        child: FaIcon(FontAwesomeIcons.plus),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search...',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: 15,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, int index){
                    return Container(
                      child: Column(
                        children: [
                          Text('judulnya'),
                          Row(
                            children: [
                              Container(
                                child: Text('first'),
                              ),
                            ],
                          ),
                          Text('some content'),
                          Row(
                            children: [
                              Text('02 Nov 2025'),
                              FaIcon(FontAwesomeIcons.trash)
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
