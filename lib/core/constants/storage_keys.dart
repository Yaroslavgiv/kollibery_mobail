/// Ключи локального хранилища.
/// Единая точка, чтобы не размазывать магические строки по проекту.
class StorageKeys {
  StorageKeys._();

  static const String loggedIn = 'loggedIn';
  static const String token = 'token';
  static const String role = 'role';
  static const String email = 'email';
  static const String userId = 'userId';
  static const String userProfile = 'userProfile';
  static const String cartItems = 'cartItems';
  static const String orderStatuses = 'order_statuses';
  static const String localHistoryCleared = 'local_history_cleared';
  static const String sellerOrderHistory = 'seller_order_history';
  static const String localOrders = 'local_orders';
}
