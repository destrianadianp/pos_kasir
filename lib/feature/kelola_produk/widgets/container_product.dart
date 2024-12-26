import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../provider/product_provider.dart';
import '../../edit_produk/edit_produk_screen.dart';

class ProdukPage extends StatelessWidget {
  final ProductCartProvider productCartProvider;
  final String searchQuery;

  const ProdukPage({
    required this.productCartProvider,
    required this.searchQuery,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final filteredProducts = searchQuery.isEmpty
        ? productCartProvider.products
        : productCartProvider.products.where((product) {
            return product.productName
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text("Tidak ada produk ditemukan."),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await productCartProvider.fetchProducts(
          FirebaseAuth.instance.currentUser!.uid,
        );
      },
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          final isInCart = productCartProvider.cartItems
              .any((item) => item.product.productId == product.productId);

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProdukScreen(product: product),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: product.productImage.isNotEmpty
                        ? Image.memory(
                            base64Decode(product.productImage),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported,
                          ),
                    title: Text(product.productName),
                    subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                    trailing: Text('Stok: ${product.stock}'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isInCart) {
                        productCartProvider.removeFromCart(product.productId);
                      } else {
                        productCartProvider.addToCart(product.productId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isInCart ? Colors.red : Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      isInCart ? "Remove" : "Add to cart",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
