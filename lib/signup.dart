// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newproject/login.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isPasswordHidden = true; //sets the password to be hidden
  bool isSigningUp = false;

  Future<void> signup() async {
    final enteredEmail = email.text.trim();
    final enteredPassword = password.text.trim();

    // Check if either field is empty.
    // If empty, show an error message and stop the function.
    if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password"),
          backgroundColor: Colors.red,
        ),
      );

      // return stops the function here.
      return;
    }

    setState(() {
      isSigningUp = true;
    });

    try {
      UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: enteredEmail,
      password: enteredPassword,
    );

    // Retrieve the user's Firestore document using their UID.
            //Example path: users/abc123uid
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userCredential.user!.uid)
        .set({
      "uid": userCredential.user!.uid,
      "email": enteredEmail,
      "role": "user",
      "createdAt": FieldValue.serverTimestamp(),
    });

await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up successful"),
          backgroundColor: Colors.green,
        ),
      );

      Get.offAll(
        const Login(),
      ); //when the sign in button is clicked the page is taken to the login page
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase sign up error: ${e.code} - ${e.message}");  //to view in colsole why firebase failed

      String message = e.message ?? "Sign up failed. Error code: ${e.code}";

      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else if (e.code == 'weak-password') {
        message = "Password should be at least 6 characters.";
      } else if (e.code == 'operation-not-allowed') {
        message = "Email/password sign up is not enabled in Firebase.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSigningUp = false;
        });
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage( //sets the backgund image
              'https://images.unsplash.com/photo-1498837167922-ddd27525d352?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1350&q=80',
            ),
            fit: BoxFit.cover, //fill the entire container by keep its aspect ratio (no stretching) and crop parts of the image if necessary.
          ),
        ),

        child: Center(
          child: Container( //creates a rectangualr box
            margin: EdgeInsets.symmetric(horizontal: 42.0),//allows for the box to be placed 30 units from the edge
            padding: EdgeInsets.symmetric(horizontal: 22.0), //this is the spacing inside the contianer
            height: MediaQuery.of(context).size.height * 0.55, //makes the UI responsive instead of being catered t only one device it will be able to resize based on the screen diemtions.
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),  //makes the box transulcent
              borderRadius: BorderRadius.circular(15.0),
            ),

          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                    // mainAxisAlignment:MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Sign Up Page',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // balances the IconButton width
                      ],
                    ),

                    const SizedBox(height: 10),
                
                
                SizedBox(height:25,),

            TextField(
              controller: email, //telling code which filed to reference at
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                hintText: "Email",
              ), //the hint that is given in the email text field
            ),
            SizedBox(height: 20),
            TextField(
              controller: password,

              ///telling code which filed to reference at
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: "Password", //sets the title of the  box
                border: const OutlineInputBorder(),
                hintText:
                    "Password", //the hint that is given in the password text field
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                  icon: Icon(
                    //eye icon
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Column(
              children: [
                ElevatedButton(
                  onPressed: isSigningUp ? null : signup,
                  child: Text(isSigningUp ? "Signing Up..." : "Sign Up"),
                ),
                //distance between the signup button and the text
                SizedBox(height: 20),

                //properties of the text displayed; already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(Login());
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}