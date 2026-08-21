/// Заказ доставки дроном.
class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.status,
    this.productName = '',
    this.productImage = '',
    this.price = 0,
    this.buyerName = '',
    this.sellerName = '',
    this.createdAt,
    this.updatedAt,
    this.productDescription = '',
    this.productCategory = '',
  });

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
  final String productDescription;
  final String productCategory;

  bool get isDelivered => status.toLowerCase() == 'delivered';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isActive => !isDelivered && !isCancelled;
}
