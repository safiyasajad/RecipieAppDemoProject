// This page controls the starting flow of the entire application.
// It decides:
// 1. whether the user is logged in
// 2. whether the user is an admin or normal user
// 3. which screen should open first

import 'package:flutter/material.dart';

// Firebase Authentication is used to detect login/logout state.
import 'package:firebase_auth/firebase_auth.dart';

// Cloud Firestore is used to retrieve the user's role
// (admin or user) from the database.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newproject/admin.dart';
import 'package:newproject/login.dart';
import 'package:newproject/screens/search_screen.dart';
// import 'package:newproject/user.dart';
import 'package:newproject/screens/search_screen.dart';

// Wrapper is a StatefulWidget because the UI changes dynamically
// depending on authentication state and Firestore data.
class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // body contains the main logic of the app startup flow.
      body: StreamBuilder(

        // authStateChanges() continuously listens for login/logout changes.
        //
        // Examples:
        // - user logs in
        // - user logs out
        // - app starts and Firebase checks saved login session
        //
        // Whenever authentication changes,
        // StreamBuilder rebuilds automatically.
        stream: FirebaseAuth.instance.authStateChanges(),
        // builder rebuilds the UI whenever the auth stream changes.
        builder: (context, snapshot) {

        
          // This prevents the app from showing blank pages or crashing
          // before Firebase finishes loading.
          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(), // While Firebase is checking the user's authentication state, show a loading spinner.
            );
          }

          // snapshot.data contains the currently logged-in Firebase user.
          //If no user is logged in, this value becomes null and user is sent to the Login page
          final user = snapshot.data;
          if (user == null) {
            return const Login();
          }

          // If the user IS logged in, we now need to determine:
          // Is this user an admin or a normal user?
          // For that, we fetch their Firestore document.
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(

            // Retrieve the user's Firestore document using their UID.
            //Example path: users/abc123uid
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get(),

            // builder runs once Firestore returns the document.
            builder: (context, userSnapshot) {

              // While Firestore is still loading user data,a loading spinner is shows
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // If Firestore fails to load:
              // - permission denied
              // - internet issue
              // - missing document
              //
              // show error message on screen.
              if (userSnapshot.hasError) {

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Text(

                      // Display actual Firestore error.
                      "Could not load user role: ${userSnapshot.error}",

                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Extract the "role" field from Firestore document. user or admin
              final role =
                  userSnapshot.data?.data()?["role"];

              // If role equals admin:
              // open Admin page else user page
              if (role == "admin") {

                return AdminPage();
              }
              //returns user screen
              return SearchScreen();
            },
          );
        },
      ),
    );
  }
}