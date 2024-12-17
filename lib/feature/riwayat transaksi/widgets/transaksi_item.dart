import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String transactionId;
  final String paymentMethod;
  final int amount;
  final String time;
  final VoidCallback onTap;

  const TransactionItem({
    Key? key,
    required this.transactionId,
    required this.paymentMethod,
    required this.amount,
    required this.time,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.receipt_long, color: Colors.grey),
      title: Text(transactionId),
      subtitle: Text(paymentMethod),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Rp${amount.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
