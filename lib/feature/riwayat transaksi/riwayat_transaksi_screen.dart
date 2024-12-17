import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_kasir/feature/riwayat%20transaksi/detail_riwayat_transaksi_screen.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../provider/transaction_provider.dart';
import 'widgets/transaksi_item.dart';
// import 'transaction_detail_page.dart';  // Pastikan file ini diimpor dengan benar.

class RiwayatTransaksiScreen extends StatefulWidget {
  const RiwayatTransaksiScreen({super.key});

  @override
  State<RiwayatTransaksiScreen> createState() => _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;
        Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransaction(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    // Filter transactions based on search query
    final filteredTransactions = transactions
        .where((transaction) =>
            transaction.id.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // Group transactions by date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in filteredTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari No. Transaksi",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Tidak ada data transaksi.",
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            User? user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              String userId = user.uid;
                              await Provider.of<TransactionProvider>(context,
                                      listen: false)
                                  .fetchTransaction(userId);
                            }
                          },
                          child: Text('Muat Ulang'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      User? user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        String userId = user.uid;
                        await Provider.of<TransactionProvider>(context,
                                listen: false)
                            .fetchTransaction(userId);
                      }
                    },
                    child: ListView.builder(
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final dateKey = sortedDates[index];
                        final transactionsByDate =
                            groupedTransactions[dateKey]!;

                        // Sort transactions within the same date by time (ascending)
                        transactionsByDate
                            .sort((a, b) => b.date.compareTo(a.date));

                        final totalAmount = transactionsByDate.fold(
                            0,
                            (sum, transaction) =>
                                sum + transaction.totalBill.toInt());

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.grey[200],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE, dd MMM yyyy', 'id_ID')
                                        .format(DateTime.parse(dateKey)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Rp${NumberFormat('#,##0', 'id_ID').format(totalAmount)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactionsByDate.length,
                              itemBuilder: (context, idx) {
                                final transaction = transactionsByDate[idx];
                                return TransactionItem(
                                  transactionId: transaction.id,
                                  paymentMethod: transaction.paymentMethod,
                                  amount: transaction.totalBill.toInt(),
                                  time: DateFormat('HH:mm')
                                      .format(transaction.date),
                                  onTap: () {
                                    // Navigasi ke halaman detail dengan mengirimkan ID transaksi
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionDetailPage(
                                                transactionId: transaction.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
