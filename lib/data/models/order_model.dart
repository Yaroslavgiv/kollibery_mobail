import '../../domain/entities/order_entity.dart';

/// DTO заказа. Расширяет доменную сущность и умеет JSON.
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.quantity,
    required super.deliveryLatitude,
    required super.deliveryLongitude,
    required super.status,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.buyerName,
    required super.sellerName,
    super.createdAt,
    super.updatedAt,
    super.productDescription = '',
    super.productCategory = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // API может вернуть id как int или String — для DELETE /order/deleteorder/{orderId} нужен int
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : (rawId != null ? (int.tryParse(rawId.toString()) ?? 0) : 0);
    // productId с сервера может быть int или String
    final rawProductId = json['productId'];
    final productId = rawProductId is int
        ? rawProductId
        : (rawProductId != null
            ? (int.tryParse(rawProductId.toString()) ?? 0)
            : 0);
    return OrderModel(
      id: id,
      userId: json['userId'] ?? '',
      productId: productId,
      quantity: json['quantity'] ?? 1,
      deliveryLatitude: (json['deliveryLatitude'] is num)
          ? (json['deliveryLatitude'] as num).toDouble()
          : 0.0,
      deliveryLongitude: (json['deliveryLongitude'] is num)
          ? (json['deliveryLongitude'] as num).toDouble()
          : 0.0,
      status: json['status'] ?? 'pending',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      // Используем productPrice если есть, иначе price
      price: (json['productPrice'] is num)
          ? (json['productPrice'] as num).toDouble()
          : ((json['price'] is num) ? (json['price'] as num).toDouble() : 0.0),
      buyerName: json['buyerName'] ?? '',
      sellerName: json['sellerName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      productDescription: json['productDescription'] ?? '',
      productCategory: json['productCategory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'status': status,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'productDescription': productDescription,
      'productCategory': productCategory,
    };
  }
}
