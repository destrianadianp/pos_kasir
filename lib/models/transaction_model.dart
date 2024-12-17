import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_kasir/models/cart_model.dart';
import 'package:pos_kasir/models/cart_product_model.dart';

class TransactionModel {
  final String id;
  final String paymentMethod;
  final double totalBill;
  final double receivedAmount;
  final double changeAmount;
  final String? note;
  final DateTime date;
  final String? userId;
  // final List<CartProductModel>cartItems;

  TransactionModel({
    required this.id,
    required this.paymentMethod,
    required this.totalBill,
    required this.receivedAmount,
    required this.changeAmount,
    this.note,
    required this.date,
     this.userId
    // required this.cartItems
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'totalBill': totalBill,
      'receivedAmount': receivedAmount,
      'changeAmount': changeAmount,
      'note': note ?? '',
      'date': Timestamp.fromDate(date),
      'userId' : userId
      // 'cartItems' : cartItems.map((cartItem)=>cartItem.toMap()).toList()
    };
  }
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      paymentMethod: data['paymentMethod'] ?? '',
      totalBill: (data['totalBill'] as num?)?.toDouble() ?? 0.0,
      receivedAmount: (data['receivedAmount'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (data['changeAmount'] as num?)?.toDouble() ?? 0.0,
      note: data['note'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId']
      // cartItems: (data['cartItems'] as List?)?.map((item) => CartModel.fromMap(item)).toList() ?? [],
    );
  }
}
