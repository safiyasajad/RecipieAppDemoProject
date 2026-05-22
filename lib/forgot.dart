import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  TextEditingController email = TextEditingController();

  Future<void> reset() async {
    final enteredEmail = email.text.trim();

    if (enteredEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: enteredEmail);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent. Check your email."),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Failed to send reset link";

      if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else if (e.code == 'user-not-found') {
        message = "No account found for this email.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
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
    }
  }

  @override
  void dispose() {
    email.dispose();
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
            margin: const EdgeInsets.symmetric(
              horizontal: 30.0, //allows for the box to be placed 30 units from the edge
            ),
            //this is the spacing inside the contianer
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 25.0,
            ),

            height: MediaQuery.of(context).size.height * 0.55, //makes the UI responsive instead of being catered t only one device it will be able to resize based on the screen diemtions.

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),  //makes the box transulcent
              borderRadius: BorderRadius.circular(15.0),
            ),

          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                    mainAxisAlignment:MainAxisAlignment.start,
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
                      ],
                    ),

                    const SizedBox(height: 10),
                Text(
                  'Forgot password?',
                  
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                
                SizedBox(height:25,),
      
            TextField(
              controller:email, //telling code which filed to reference at
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                hintText: "Enter Email") //the hint that is given in the email text field
            ),
            
            SizedBox(height: 20),
            ElevatedButton(onPressed: (()=>reset()), child: Text("Send Link"),),
              ],
            ),
          ),
        ),
       ),
    );
  }
}
