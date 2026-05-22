import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserPage extends StatelessWidget {
  const UserPage({super.key});

  Future<void> signout() async{
    await FirebaseAuth.instance.signOut(); //signs user out of application. 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User")),
      body: const Center(
        child: Text("User Page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>signout()),
        child: Icon(Icons.login_rounded)
        ), 
    );
  }
}