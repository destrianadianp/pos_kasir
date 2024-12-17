// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/kelola_produk/kelola_produk_screen.dart';
import 'package:pos_kasir/feature/tambah_produk/widgets/image_picker.dart';
import 'package:pos_kasir/feature/ui/dimension.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_button.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_text_form_field.dart';
import 'package:provider/provider.dart';
// import '../../provider/product_cart_provider.dart';
import '../../provider/category_provider.dart';
import '../../models/product_model.dart';
import '../../provider/product_provider.dart';

class TambahProduk extends StatefulWidget {
  const TambahProduk({super.key});

  @override
  State<TambahProduk> createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final _namaProdukController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  String dropdownValue = '';
  String? base64Image;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final productCartProvider = Provider.of<ProductCartProvider>(context);

    final kategoriList = categoryProvider.categories;

    if (kategoriList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Produk"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImagePickerWidget(onImagePicked: (base64) {
                  setState(() {
                    base64Image = base64;
                  });
                }),
                SizedBox(
                  height: space300,
                ),
                CustomTextFormField(
                  controller: _namaProdukController,
                  placeholder: 'Nama Barang',
                ),
                CustomTextFormField(
                  controller: _hargaJualController,
                  placeholder: 'Harga',
                  keyboardType: TextInputType.number,
                ),
                CustomTextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  placeholder: 'Stok',
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(borderRadius100))),
                  value: dropdownValue.isEmpty ? null : dropdownValue,
                  items: kategoriList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
                const SizedBox(height: space800),
                CustomButton(
                  onPressed: () async {
                    // TODO: Bisa diperbaiki agar lebih mudah dibaca
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final String userId = auth.currentUser!.uid;

                    try {
                      final newProduct = {
                        "productId": DateTime.now().toString(),
                        "productName": _namaProdukController.text,
                        "productImage":
                            base64Image ?? '', // Atur jika menggunakan gambar
                        "price": double.parse(_hargaJualController.text),
                        "stock": int.parse(_stokController.text),
                        "category": dropdownValue,
                        "userId": userId,
                      };

                      // Simpan produk ke Firebase
                      await FirebaseFirestore.instance
                          .collection('products')
                          .add(newProduct);

                      // Tampilkan notifikasi sukses
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Produk berhasil ditambahkan")),
                      );

                      // Arahkan kembali ke halaman Kelola Produk
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const KelolaProdukPage()),
                      );
                    } catch (e) {
                      // Tampilkan notifikasi error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Terjadi kesalahan: $e")),
                      );
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
