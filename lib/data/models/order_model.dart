class OrderModel {
  final int id;
  final String userId;
  final int productId;
  final int quantity;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String status;
  final String productName;
  final String productImage;
  final double price;
  final String buyerName;
  final String sellerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Дополнительная информация о товаре
  final String productDescription;
  final String productCategory;

  OrderModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.status,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.buyerName,
    required this.sellerName,
    this.createdAt,
    this.updatedAt,
    this.productDescription = '',
    this.productCategory = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? 0,
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
