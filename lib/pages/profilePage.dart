import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _addressController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null) {
        setState(() {
          _addressController.text = data['address'] ?? '';
          _isEditing = false; // Always reset to view-only mode on page load
        });
      }
    }
  }

  void _saveAddress() async {
    final address = _addressController.text.trim();
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'address': address,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Address updated successfully!")),
    );

    setState(() {
      _isEditing = false; // Switch back to view-only mode after saving
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Profile",
          style: GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(_auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No data found."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] ?? "Unknown";
          final email = userData['email'] ?? "Unknown";
          final profilePhoto = userData['profilePicture'] ??
              "https://via.placeholder.com/150"; // Default placeholder image

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Photo
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profilePhoto),
                ),
                SizedBox(height: 16),
                // Name
                Text(
                  name,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                // Email Address
                Text(
                  email,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 24),
                // Address Section
                // Address Section
                Card(
                  color: Colors.white, // White background for the card
                  elevation: 8, // Elevation for shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.yellow.shade800, // Yellow shadow color
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Address",
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        _isEditing
                            ? TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: "Enter your address",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                        )
                            : Text(
                          _addressController.text.isEmpty
                              ? "No address added. Please edit to add your address."
                              : _addressController.text,
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isEditing)
                              ElevatedButton(
                                onPressed: _saveAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow.shade800,
                                  padding:
                                  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                child: Text(
                                  "Save",
                                  style: GoogleFonts.fredoka(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow.shade800,
                                  padding:
                                  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                child: Text(
                                  "Edit",
                                  style: GoogleFonts.fredoka(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
