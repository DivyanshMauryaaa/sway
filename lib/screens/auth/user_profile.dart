import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final User? user =
      FirebaseAuth.instance.currentUser; //Get current logged-in user.

  //User variables declearations
  late String uid;
  late String displayName;
  late String email;
  late String photoURL;

  @override
  void initState() {
    super.initState();

    //Get user details
    uid =
        user?.uid ??
        'No user ID:: error please contact support for more details';
    displayName = user?.displayName ?? 'Please set your name';
    email = user?.email ?? 'Please set your email';
    photoURL = user?.photoURL ?? 'https://placehold.co/70';
  }

  Future<void> updateUserProfile({String? newName, String? newPhotoUrl}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updateDisplayName(newName);
        await user.updatePhotoURL(newPhotoUrl);
        await user.reload(); // important to refresh the data!

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User Updated Successfuly!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(''),
            ),

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
                                    String NewPhotoURL =
                                        photoURLController.text.isNotEmpty
                                            ? photoURLController.text
                                            : photoURL;

                                            updateUserProfile(
                                              newName: newName,
                                              newPhotoUrl: NewPhotoURL
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
                TextButton(onPressed: () {
                  FirebaseAuth.instance.signOut();
                }, child: Text("Log out")),
              ],
            ),

            Text(
              displayName,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 25),
            ),

            SizedBox(height: 10),

            Text(
              email,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
