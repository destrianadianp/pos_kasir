import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/tambah_produk/widgets/image_picker.dart';
import 'package:pos_kasir/feature/ui/dimension.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_button.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_text_form_field.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../provider/product_provider.dart';

class EditProdukScreen extends StatefulWidget {
  final ProductModel product;

  const EditProdukScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  late TextEditingController _namaProdukController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
String? updatedBase64Image;

 
  @override
  void initState() {
    super.initState();
    _namaProdukController = TextEditingController(text: widget.product.productName);
    _hargaController = TextEditingController(text: widget.product.price.toString());
    _stokController = TextEditingController(text: widget.product.stock.toString());
  }

   Future<void> _updateProduct() async {
  // Data yang akan diperbarui
  final updatedProduct = {
    'productImage':updatedBase64Image ?? widget.product.productImage,
    'productName': _namaProdukController.text.trim(),
    'price': double.parse(_hargaController.text.trim()),
    'stock': int.parse(_stokController.text.trim()),
  };

  print('Product ID: ${widget.product.productId}');
  print('Data yang dikirim: $updatedProduct');

  try {
    // Perbarui data di Firestore
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.productId) // Pastikan ID produk sesuai
        .update(updatedProduct);

    // print('Data berhasil diperbarui di Firebase');

    // Sinkronisasi dengan UI
    Provider.of<ProductCartProvider>(context, listen: false).fetchProducts(widget.product.userId);

    // Tampilkan notifikasi sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil diperbarui")),
    );
    // Kembali ke layar sebelumnya
    Navigator.pop(context);
  } catch (e) {
    // Tangani kesalahan
    print('Error saat memperbarui data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}


Future <void> _deletedProduct() async {
  final deleteProduct = {
    ('productId : ${widget.product.productId}')
  };
  try {
    await FirebaseFirestore.instance
    .collection('products')
    .doc(widget.product.productId)
    .delete();
    Provider.of<ProductCartProvider>(context, listen: false).fetchProducts(widget.product.userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil dihapus")),
    );
    // Kembali ke layar sebelumnya
    Navigator.pop(context);
  } catch (e) {
    // Tangani kesalahan
    print('Error saat menghapus data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
    
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImagePickerWidget(
              initialImage:widget.product.productImage,
              onImagePicked: (base64){
                updatedBase64Image=base64;
              }),
            const SizedBox(height: 16.0),
            CustomTextFormField(
              controller: _namaProdukController,
            ),
            CustomTextFormField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
            ),
            CustomTextFormField(
              controller: _stokController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: space400),
            TextButton(onPressed: () async {
              await _deletedProduct();
            }, 
            child: Text("Hapus Produk")),
            const SizedBox(height: space400),

            // Tombol Simpan
            CustomButton(
              onPressed: () async {
                await _updateProduct();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
