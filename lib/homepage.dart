import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final user = FirebaseAuth.instance.currentUser; //retreieving data for any of the currently logged in users

  Future<void> signout() async{
    await FirebaseAuth.instance.signOut(); //signs user out of application. 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Home Page"),),
      body: Center(
        child:Text('${user!.email}'),
      ),
      //signout button at the bottom of the page (similiar to the one same as the + button on bottom right corner)

      //look into also changing this to a sentral button
      floatingActionButton: FloatingActionButton(
        onPressed: (()=>signout()),
        child: Icon(Icons.login_rounded)
        ),   
    );
  }
}
