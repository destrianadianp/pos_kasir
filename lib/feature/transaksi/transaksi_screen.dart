import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/pembayaran_tunai/pembayaran_tunai_screen.dart';
import 'package:provider/provider.dart';

import '../../provider/product_provider.dart';
import '../ui/shared_view/custom_button.dart';
import '../ui/shared_view/custom_text_form_field.dart';
import '../ui/typography.dart';
import '../ui/color.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  @override
  Widget build(BuildContext context) {
    final productCartProvider = Provider.of<ProductCartProvider>(context);

    double totalProductPrice = productCartProvider.cartItems.fold(0.0, (sum, item) {
      final price = item.product.price ?? 0;
      final quantity = item.quantity ?? 1;
      return sum + (price * quantity);
    });

    double totalPayment = totalProductPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaksi"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Total: ${productCartProvider.totalCartItems} items",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: productCartProvider.cartItems.isEmpty
          ? _buildEmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: productCartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = productCartProvider.cartItems[index];
                      final product = cartItem.product;

                      return ListTile(
                        leading: product.productImage.isNotEmpty
                            ? Image.memory(
                                base64Decode(product.productImage),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(product.productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Harga: Rp${product.price.toStringAsFixed(0)}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                productCartProvider.minusQuantity(product.productId);
                              },
                            ),
                            Text("${cartItem.quantity}"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                productCartProvider.addQuantity(product.productId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (productCartProvider.cartItems.isNotEmpty)
                  _buildPaymentSection(context, totalPayment),
              ],
            ),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/img_empty_cart.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            "Keranjang Masih Kosong",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Silahkan tambahkan produk ke keranjang melalui katalog",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, double totalPayment) {
    final catatanController = TextEditingController();
    bool isSwitchOn = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rp ${totalPayment.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("Tunai"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PembayaranTunaiScreen(
                        totalPayment: totalPayment,
                        note: isSwitchOn?catatanController.text:null),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("Pembayaran online"),
                subtitle: const Text("Terima pembayaran melalui virtual account dan e-wallet"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Ingin catatan tambahan?\nKamu bisa menambahkan catatan untuk setiap transaksimu",
                      style: sRegular.copyWith(color: textDisabled),
                    ),
                  ),
                  Switch(
                    value: isSwitchOn,
                    onChanged: (value) {
                      setState(() {
                        isSwitchOn = value;
                      });
                    },
                  ),
                ],
              ),
              if (isSwitchOn)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CustomTextFormField(
                    controller: catatanController,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
