import 'package:hive/hive.dart';

part 'menuitem.g.dart';

@HiveType(typeId: 0)
class MenuItem {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String imagePath;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: (json['price']).toDouble(),
      description: json['description'] ?? 'No Description',
      imagePath: json['image'] ?? 'assets/default_food.png',
    );
  }
}
