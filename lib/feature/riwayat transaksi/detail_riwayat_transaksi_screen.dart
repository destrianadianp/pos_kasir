import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({Key? key, required this.transactionId}) : super(key: key);

  Future<Map<String, dynamic>> fetchTransactionDetails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .doc(transactionId)
        .get();

    if (snapshot.exists) {
      return snapshot.data()!;
    }
    throw Exception("Transaction not found");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$transactionId"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          for (var key in data.keys) {
            print("$key: ${data[key]}");
          }

          final paymentMethod = data['paymentMethod'] ?? 'Unknown';
          // final transactionDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(data['date']));
          final transactionDate = DateTime.now().toString();
          final cartItems = data['cartItems']; // Assuming cartItems is a list of items in the transaction
          final totalAmount = data['totalBill'];
          final receivedAmount = data['receivedAmount'];
          final changeAmount = data['changeAmount'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(label: "Tipe Pembayaran", value: paymentMethod),
                        DetailRow(label: "Tanggal Transaksi", value: transactionDate),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ExpansionTile(
                  title: Text("Detail Pembelian", style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cartItems.map<Widget>((item) {
                          return DetailRow(
                            label: item['product']['productName'],
                            value: "Rp${item['product']['price']} x ${item['quantity']}",
                            trailing: "Rp$totalAmount",
                          );
                        }).toList(),
                      ),
                    ),
                    Divider(),
                    DetailRow(label: "Subtotal", trailing: "Rp$totalAmount"),
                    DetailRow(label: "Dibayar", trailing: "Rp$receivedAmount"),
                    DetailRow(label: "Kembalian", trailing: "Rp$changeAmount"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? trailing;
  final bool isBold;

  const DetailRow({required this.label, this.value, this.trailing, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          if (value != null)
            Text(value!, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          if (trailing != null)
            Text(trailing!, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
