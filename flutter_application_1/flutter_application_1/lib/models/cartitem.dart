import 'package:hive/hive.dart';

part 'cartitem.g.dart';

@HiveType(typeId: 1)
class CartItem {
  @HiveField(0)
  final int menuItemId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  int cartId;

  @HiveField(5)
  final int? id;  // nullable if sometimes missing

  CartItem({
    this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.cartId,
    this.quantity = 1,
  });
factory CartItem.fromJson(Map<String, dynamic> json) {
  final menuItemJson = json['menuItem'] ?? {};

  return CartItem(
    id: json['id'] as int?,
    menuItemId: menuItemJson['id'] ?? 0,
    name: menuItemJson['name'] ?? '',
    price: (menuItemJson['price'] is int)
        ? (menuItemJson['price'] as int).toDouble()
        : (menuItemJson['price'] as double? ?? 0.0),
    quantity: json['quantity'] ?? 1,
    cartId: 0, // no cartId from backend? adjust as needed
  );
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItemId': menuItemId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'cartId': cartId,
      };
}
