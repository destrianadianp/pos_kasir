import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_kasir/feature/kelola_produk/kelola_produk_screen.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction_model.dart';
import '../../provider/product_provider.dart';
import '../../provider/transaction_provider.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final double receivedAmount;
  final double totalBill;
  final String? note;

  const TransactionSuccessScreen({
    super.key,
    required this.receivedAmount,
    required this.totalBill,
    this.note
  });

  @override
  _TransactionSuccessScreenState createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  String paymentMethod = 'Tunai';
  double changeAmount = 0.0;
  String transactionTime = '';

  @override
  void initState() {
    super.initState();
    _calculateChange();
    _setTransactionTime();
  }

  void _calculateChange() {
    setState(() {
      changeAmount = widget.receivedAmount - widget.totalBill;
    });
  }

  void _setTransactionTime() {
    setState(() {
      transactionTime = DateFormat('dd-MMM-yyyy, HH:mm').format(DateTime.now());

      final String transactionId = const Uuid().v4();
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final transaction = TransactionModel(
        id: transactionId, 
        paymentMethod: paymentMethod, 
        totalBill: widget.totalBill, 
        receivedAmount: widget.receivedAmount, 
        changeAmount: changeAmount, 
        note: widget.note,
        date: DateTime.now(),
        userId: userId);

        FirebaseFirestore.instance
        .collection('transaction')
        .doc(transactionId)
        .set(transaction.toMap())
        .then((_)=>print("Transaksi berhasil disimpan"))
        .catchError((error)=>print("Transaksi gagal dilakukan:$error"));

        Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(transaction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              'Transaksi Berhasil',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              transactionTime,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            transactionDetailsWidget(
              paymentMethod: paymentMethod,
              totalBill: widget.totalBill,
              receivedAmount: widget.receivedAmount,
              changeAmount: changeAmount,
            ),
            const Spacer(),
            CustomButton(
              child: const Text("Transaksi Baru"),
              onPressed: () {
                Provider.of<ProductCartProvider>(context, listen: false)
                    .clearCart();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const KelolaProdukPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionDetailsWidget({
    required String paymentMethod,
    required double totalBill,
    required double receivedAmount,
    required double changeAmount,
  }) {
    return Column(
      children: [
        transactionDetailRow(title: 'Pembayaran', value: paymentMethod),
        transactionDetailRow(
            title: 'Total Tagihan', value: 'Rp${totalBill.toStringAsFixed(0)}'),
        transactionDetailRow(
            title: 'Diterima', value: 'Rp${receivedAmount.toStringAsFixed(0)}'),
        transactionDetailRow(
          title: 'Kembalian',
          value: 'Rp${changeAmount.toStringAsFixed(0)}',
          valueStyle: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }

  Widget transactionDetailRow({
    required String title,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: valueStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
