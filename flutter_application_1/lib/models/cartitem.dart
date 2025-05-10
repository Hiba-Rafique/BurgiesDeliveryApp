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

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.cartId,
    this.quantity = 1,
  });
}
