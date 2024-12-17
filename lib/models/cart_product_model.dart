class CartProductModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  CartProductModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartProductModel.fromMap(Map<String, dynamic> map) {
    return CartProductModel(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
