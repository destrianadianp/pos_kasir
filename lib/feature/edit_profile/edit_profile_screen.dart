import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../ui/shared_view/custom_button.dart';
import '../ui/shared_view/custom_image_picker.dart';
import '../ui/shared_view/custom_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _profileImageUrl;
  File? _profileImage;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    getUser();

    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _profileImageUrl = '';

    // Inisialisasi dengan data dari Firebase
    /* _usernameController = TextEditingController(text: widget.user.userName);
    _emailController = TextEditingController(text: widget.user.email); */

    /* FirebaseAuth.instance.currentUser?.reload().then((_) {
      final currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _usernameController.text =
            (currentUser?.displayName ?? widget.user.userName)!;
      });
    }); */
  }

  Future<void> getUser() async {
    final Map<String, dynamic> currentUserData = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then(
          (value) => value.data() as Map<String, dynamic>,
        );
    setState(() {
      _usernameController.text = currentUserData['userName'];
      _emailController.text = currentUserData['email'];
      if (currentUserData.containsKey('imageUrl')) {
        _profileImageUrl = currentUserData['imageUrl'];
        _profileImageBytes = base64Decode(_profileImageUrl);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Atur Profil"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.file(
                          _profileImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _profileImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.memory(
                              _profileImageBytes!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.account_circle,
                            size: 120,
                            color: Colors.grey,
                          ),
                /* CircleImageView(
                  url: _profileImageUrl,
                  imageType: ImageType.network,
                  radius: 60,
                ), */
                CustomImagePicker(
                  onImageSelected: (File? selectedImage) {
                    setState(() {
                      _profileImage = selectedImage;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    // TextFormField untuk Username
                    CustomTextFormField(
                      placeholder: 'Username',
                      controller: _usernameController,
                    ),

                    // TextFormField untuk Email (read-only)
                    CustomTextFormField(
                      placeholder: 'Email',
                      controller: _emailController,
                      enabled: false, // Email tidak dapat diedit
                    ),

                    const SizedBox(height: 20),
                    CustomButton(
                      child: const Text("Simpan"),
                      onPressed: () {
                        Navigator.pop(context);
                        _saveUserProfile();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUserProfile() async {
    try {
      // Dapatkan userId dari Firebase
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Update data pengguna di Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userName': _usernameController.text,
        'email': _emailController.text,
        'imageUrl': _profileImage != null
            ? base64Encode(_profileImage!.readAsBytesSync())
            : _profileImageUrl,
      });

      /*
      // Simpan username yang baru ke Firebase
      final user = FirebaseAuth.instance.currentUser;

      // Jika pengguna tidak null (sudah login)
      if (user != null) {
        // Update displayName di Firebase Authentication
        await user.updateDisplayName(_usernameController.text);
        await user.reload(); // Refresh data pengguna di Firebase

        // Perbarui model lokal
        final updatedUser = UserModel(
          id: widget.user.id,
          email: widget.user.email,
          userName: _usernameController.text,
        );

        // Menampilkan data yang disimpan untuk debugging
        print("Updated User: ${updatedUser.userName}");
        print("Updated Profile Image: $_profileImage");

        // Feedback sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
      }
      */
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }
}
