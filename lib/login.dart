import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newproject/signup.dart';
import 'package:newproject/wrapper.dart';
import 'package:newproject/forgot.dart';
import 'package:get/get.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  TextEditingController email =TextEditingController();
  TextEditingController password =TextEditingController(); 

  bool isPasswordHidden = true; //sets the password to be hidden
  bool isSigningIn = false; // Controls login loading state. disable login button while processing
  //stopping multiple requests to be made before 1 is processed
  // - show "Signing in..." text

  // This function runs when the user presses the Login button.
  Future<void> signIn() async {
    // Get the email typed by the user.
    // .trim() removes spaces at the start and end.
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

    // Update UI state.
    //
    // This rebuilds the screen and:
    // - disables button
    // - changes button text to "Signing in..."
    
    setState(() {
      isSigningIn = true;
    });

    try {
      // This sends the email and password to Firebase Authentication.
      // Firebase checks if the account exists and if the password is correct.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // After an async operation, the widget may no longer be on screen.
      // mounted checks if this screen still exists before using context.
      if (!mounted) return;

      // If Firebase login is successful, show success message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login successful"),
          backgroundColor: Colors.green,
        ),
      );

      Get.offAll(const Wrapper());
    } on FirebaseAuthException catch (e) {
      // This block catches errors specifically from Firebase Authentication.
      // where email does not exist, wrong password, invalid email format

      // Default error message.
      String message = "Login failed";

      // If Firebase says the password is wrong.
      if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      }

      // If the email format is invalid, for example missing @.
      else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      }

      // Newer Firebase versions often return this for wrong email/password.
      else if (e.code == 'invalid-credential') {
        message = "Credentials not recognised. Please sign up";
      }

      // Check if screen still exists before showing SnackBar.
      if (!mounted) return;

      // Show the error message at the bottom of the screen.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // This catches any other unexpected error that is not a FirebaseAuthException.

      if (!mounted) return;

      // Show general error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally { // finally always runs: whether login succeeds or fails
      if (mounted) {
        setState(() {   // Reset loading state.
          isSigningIn = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Controllers use memory.
    // dispose() cleans them up when the screen is removed.
    email.dispose();
    password.dispose();

    // Always call the parent dispose method at the end.
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
              horizontal: 30.0,
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
                Text(
                  'Login Page',
                  
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
                hintText: "Email") //the hint that is given in the email text field
            ),
            SizedBox(height:25,),

            //textfield for the password box
            TextField(
              controller: password,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                labelText: "Password", //sets the title of the  box
                border: const OutlineInputBorder(),
                hintText: "Password", //hint of the box
                suffixIcon: IconButton( 
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                  icon: Icon( //eye icon
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),
            
            SizedBox(height:25,),
            
            ElevatedButton(
              onPressed: isSigningIn ? null : signIn,
              
              //Change button text dynamically.
              child: Text(isSigningIn ? "Signing in..." : "Login"),
            ), //when login button is clicked it signs in the user
            SizedBox(height:25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "New to the app? ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(Signup());
                  },
                  child: Text(
                    "Create an account",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height:25,),
            //changing the feel of the forget password button


            Row(
              mainAxisAlignment: MainAxisAlignment.end, //makes the texton the right side of the screen 
              children: [
                GestureDetector( //pressing of the button
                  onTap: () {
                    Get.to(Forgot()); //where the screen is directed to when the 'forget password?' button is pressed
                  },
                  child: Text(
                    "Forgot Password?", //output text
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
          ),
        ),
       )
    );
  }
}