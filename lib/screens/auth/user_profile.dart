import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sway/screens/auth/login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final User? user =
      FirebaseAuth.instance.currentUser; // Get current logged-in user

  final db = 
      FirebaseFirestore.instance;

  // User variables
  String uid = '';
  String displayName = 'Loading...';
  String email = 'Loading...';
  String photoURL = '';

  @override
  void initState() {
    super.initState();

    // Check if user is logged in
    if (user == null) {
      // Redirect to login page if not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      });
      return;
    }

    // Get user details from Firebase Auth
    uid = user?.uid ?? 'No user ID:: error please contact support for more details';
    email = user?.email ?? 'Please set your email';

    // Fetch user data from Firestore
    getUserDataByUserId();
  }

  Future<void> getUserDataByUserId() async {
    // Get the current logged-in user's UID from Firebase Auth
    String uid = user?.uid ?? 'No user UID';

    if (uid != 'No user UID') {
      try {
        // Query Firestore collection for documents where 'user_id' matches the current UID
        QuerySnapshot userDocs =
            await FirebaseFirestore.instance
                .collection('users')
                .where('user_id', isEqualTo: uid) // Filtering by user_id field
                .get();

        // Check if any document is found
        if (userDocs.docs.isNotEmpty) {
          // Get the first matching document (assuming user_id is unique)
          var userDoc = userDocs.docs.first;

          // Access the data in the document
          var userData = userDoc.data() as Map<String, dynamic>;

          // Extract user data
          String getDisplayName = userData['displayName'] ?? 'No name';
          String getEmail = userData['email'] ?? 'No email';
          String getPhotoUrl = userData['profilePic'] ?? 'https://i.ibb.co/0r00000/default-profile-pic.png';

          setState(() {
            displayName = getDisplayName;
            photoURL = getPhotoUrl;
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Sorry, user was not found")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("There was an error displaying your details, $e"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please log in to get your details.")));
    }
  }

  Future<void> updateUserProfile({
    required String newName,
    required String newPhotoURL,
  }) async {
    try {
      // Reference to the Firestore collection
      DocumentReference userDocRef = db.collection('users').doc(uid);

      // Update the document
      await userDocRef.update({
        'displayName': newName,
        'photoURL': newPhotoURL,
      });

      // Also update Firebase Auth profile
      await user?.updateDisplayName(newName);
      await user?.updatePhotoURL(newPhotoURL);

      // Reload user after update to get new values
      await user?.reload();

      // Set updated data to local variables
      setState(() {
        displayName = newName;
        photoURL = newPhotoURL;
      });

      print("Profile updated successfully.");
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // Profile picture container
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(photoURL)),
            SizedBox(height: 16),

            // Name and Email display
            Text(
              "Hi, $displayName",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 25),
            ),
            
            Text(
              email,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            SizedBox(height: 15),

            // Edit Profile and Log Out buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        final TextEditingController nameController =
                            TextEditingController();
                        final TextEditingController photoURLController =
                            TextEditingController();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Name",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: photoURLController,
                                decoration: InputDecoration(
                                  labelText: "Photo URL",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  String newName =
                                      nameController.text.isNotEmpty
                                          ? nameController.text
                                          : displayName;
                                  String newPhotoURL =
                                      photoURLController.text.isNotEmpty
                                          ? photoURLController.text
                                          : photoURL;

                                  updateUserProfile(
                                    newName: newName,
                                    newPhotoURL: newPhotoURL,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text("Save"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text("Edit Profile"),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: Text("Log out"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
