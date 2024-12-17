import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  Future<void> fetchTransaction(String userId) async {
    try {
      final snapshot = await _firestore
      .collection('transaction')
      .where('userId', isEqualTo: userId)
      .get();
      _transactions.clear();
      _transactions.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();

          return TransactionModel(
            id: doc.id,
            paymentMethod: data['paymentMethod'] ?? '',
            totalBill: (data['totalBill'] as num?)?.toDouble() ?? 0.0,
            receivedAmount: (data['receivedAmount'] as num?)?.toDouble() ?? 0.0,
            changeAmount: (data['changeAmount'] as num?)?.toDouble() ?? 0.0,
            note: data['note'] ?? '',
            date: (data['date'] as Timestamp).toDate(),
            userId: userId
            
          );
        }).toList(),
      );
      notifyListeners(); // Memastikan UI mendapatkan notifikasi pembaruan
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners(); // Update UI setelah transaksi ditambahkan
  }


  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}
