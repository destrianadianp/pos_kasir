import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import 'package:collection/collection.dart';

class ProductCartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<ProductModel> _products = []; // Daftar semua produk
  final List<CartModel> _cartItems = []; // Daftar produk di keranjang

  List<ProductModel> get products => _products; // Getter untuk produk
  List<CartModel> get cartItems => _cartItems; // Getter untuk keranjang

  Future<void> fetchProducts(String userId) async {
    try {
      final snapshot = await _firestore.collection('products').where('userId', isEqualTo: userId).get();
      log('fetchProducts: $snapshot');
      _products.clear();
      _products.addAll(snapshot.docs.map((doc) {
        final data = doc.data();

        return ProductModel(
            productId: doc.id,
            productName: data['productName'] ?? '',
            productImage: data['productImage'] ?? '',
            price: (data['price'] ?? 0).toDouble(),
            stock: data['stock'] ?? 0,
            category: data['category'] ?? '',
            userId: userId);
      }).toList());

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  Future<void> updateStockInFirebase(
      String userId, String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
      });
      notifyListeners(); // Memberitahu bahwa data sudah diupdate
    } catch (e) {
      debugPrint("Error updating stock: $e");
    }
  }

  Future<void> processOrder() async {
    // Iterasi melalui setiap item dalam keranjang
    for (var cartItem in _cartItems) {
      final userId = _auth.currentUser!.uid;
      final product = cartItem.product;
      final newStock = product.stock - cartItem.quantity;

      // Update stok di Firebase
      await updateStockInFirebase(userId, product.productId, newStock);

      // Update stok lokal (di dalam aplikasi)
      product.stock = newStock;
    }

    // Setelah selesai, hapus item dari keranjang
    clearCart();
  }

  // Tambahkan produk ke daftar produk
  Future<void> addProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(product.userId)
          .collection('products')
          .add(product.toMap());
      debugPrint("Produk berhasil ditambahkan oleh user: ${product.userId}");
    } catch (e) {
      debugPrint("Error adding product: $e");
    }
  }

  // Tambahkan produk ke keranjang
  Future<void> addToCart(String productId) async {
    final userId = _auth.currentUser!.uid;
    final product = _products.firstWhere((item) => item.productId == productId);

    if (product.stock > 0) {
      final existingCartItem = _cartItems.firstWhere(
        (cartItem) => cartItem.product.productId == productId,
        orElse: () => CartModel(product: product, quantity: 0),
      );

      if (!_cartItems.contains(existingCartItem)) {
        _cartItems.add(existingCartItem);
      }

      existingCartItem.quantity += 1;
      product.stock -= 1;

      // Update the stock in Firestore
      await updateStockInFirebase(userId, product.productId, product.stock);

      notifyListeners(); // Notify UI about the change
    }
  }

  // Kurangi kuantitas produk di keranjang
  void minusQuantity(String productId) {
    final cartItem = _cartItems.firstWhereOrNull(
      (item) => item.product.productId == productId,
    );

    if (cartItem != null) {
      cartItem.quantity -= 1;
      final product =
          _products.firstWhere((item) => item.productId == productId);
      product.stock += 1; // Tambahkan kembali stok produk

      if (cartItem.quantity == 0) {
        _cartItems.remove(cartItem); // Hapus dari keranjang jika kuantitas 0
      }

      notifyListeners();
    }
  }

  // Tambahkan kuantitas produk di keranjang
  void addQuantity(String productId) {
    final cartItem = _cartItems.firstWhereOrNull(
      (item) => item.product.productId == productId,
    );

    if (cartItem != null) {
      final product =
          _products.firstWhere((item) => item.productId == productId);

      if (product.stock > 0) {
        cartItem.quantity += 1;
        product.stock -= 1; // Kurangi stok produk
        notifyListeners();
      }
    }
  }

  // Hapus semua kuantitas dari keranjang
  void removeFromCart(String productId) {
    final cartItem = _cartItems.firstWhereOrNull(
      (item) => item.product.productId == productId,
    );

    if (cartItem != null) {
      final product =
          _products.firstWhere((item) => item.productId == productId);
      product.stock += cartItem.quantity; // Kembalikan stok ke produk
      _cartItems.remove(cartItem); // Hapus dari keranjang
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Hitung total item di keranjang
  int get totalCartItems =>
      _cartItems.fold(0, (total, item) => total + item.quantity);
}
