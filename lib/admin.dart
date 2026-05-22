import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> signout() async{
    await FirebaseAuth.instance.signOut(); //signs user out of application. 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin")),
      body: const Center(
        child: Text("Admin Page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>signout()),
        child: Icon(Icons.login_rounded)
        ),
    );
  }
}