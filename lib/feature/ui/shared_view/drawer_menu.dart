import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/authentication/login/login_screen.dart';
import 'package:pos_kasir/feature/kelola_produk/kelola_produk_screen.dart';
import 'package:pos_kasir/feature/edit_profile/edit_profile_screen.dart';
import 'package:pos_kasir/feature/riwayat%20transaksi/detail_riwayat_transaksi_screen.dart';
import 'package:pos_kasir/feature/riwayat%20transaksi/riwayat_transaksi_screen.dart';
import 'package:pos_kasir/feature/transaksi/transaksi_screen.dart';
import 'package:pos_kasir/feature/ui/dimension.dart';

import '../../../models/user.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan pengguna yang sedang login
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView( 
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                // Menampilkan gambar profil jika ada
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: currentUser?.photoURL != null
                            ? NetworkImage(currentUser!.photoURL!)
                            // : AssetImage('assets/images/profile.jpg') as ImageProvider,
                            : snapshot.hasData
                                ? NetworkImage(snapshot.data!['imageUrl'])
                                : const AssetImage('assets/images/profile.jpg')
                                    as ImageProvider,
                      );
                    }),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser?.uid)
                              .get(),
                          builder: (context, snapshot) {
                            return Text(
                              // currentUser?.displayName ?? 'Nama Tidak Tersedia',  // Menampilkan nama pengguna
                              snapshot.hasData
                                  ? snapshot.data!['userName']
                                  : 'Nama Tidak Tersedia',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          }),
                      Text(
                        currentUser?.email ??
                            'Email Tidak Tersedia', // Menampilkan email pengguna
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  child: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (currentUser != null) {
                      // Konversi User (Firebase) ke UserModel
                      UserModel userModel = UserModel(
                        id: currentUser.uid,
                        email: currentUser.email,
                        userName:
                            currentUser.displayName ?? 'Nama Tidak Tersedia',
                      );

                      // Navigasi ke EditProfileScreen dengan userModel
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(user: userModel),
                        ),
                      );
                    } else {
                      // Tampilkan pesan error jika pengguna tidak ditemukan
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Pengguna tidak ditemukan")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Kelola Produk'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KelolaProdukPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Transaksi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransaksiPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Transaksi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RiwayatTransaksiScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan Privasi'),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetailPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Syarat dan Ketentuan'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: space500),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              // _showDeleteAccountDialog(context);
            },
            child:
                const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Akun"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus akun? Semua data Anda akan dihapus secara permanen dan tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                // Fungsi untuk menghapus akun dapat diterapkan di sini
                print("Akun dihapus");
                Navigator.pop(context);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
