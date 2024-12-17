import 'product_model.dart';

class CartModel {
  ProductModel product;
  int quantity;

  CartModel({
    required this. product,
    required this.quantity
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }
}