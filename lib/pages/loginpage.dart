import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);


  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get user details
      User? user = userCredential.user;
      if (user != null) {
        // Store user data (email and name) in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'profilePicture': user.photoURL ?? '', // Optionally store profile picture URL
          'cart': {}, // Initialize an empty cart map
        });

        // Navigate to the home page on success
        Navigator.pushNamed(context, '/userHome');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In Failed',
            style: GoogleFonts.fredokaOne(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Section (White Background)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 100, color: Colors.yellow.shade800),
                    const SizedBox(height: 20),
                    Text(
                      'Order Food within seconds',
                      style: GoogleFonts.fredokaOne(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Section (Colored Background)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.yellow.shade700,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // Admin Dashboard (Placeholder)
                      },
                      child: Text(
                        'Sign In as Admin',
                        style: GoogleFonts.fredokaOne(
                          color: Colors.yellow.shade800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // Call Google Sign-In for User
                        signInWithGoogle(context);
                      },
                      child: Text(
                        'Sign In as User',
                        style: GoogleFonts.fredokaOne(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
