import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newproject/widgets/auth_floating_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth
      .instance
      .currentUser; //retreieving data for any of the currently logged in users

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(child: Text('${user!.email}')),
      //signout button at the bottom of the page (similiar to the one same as the + button on bottom right corner)

      //look into also changing this to a sentral button
      floatingActionButton: const AuthFloatingButton(),
    );
  }
}
