import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/menuitem.dart';

class MenuItemDetailPage extends StatelessWidget {
  final MenuItem item;

  const MenuItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(item.imagePath, width: 250, height: 200, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text(item.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(item.description),
            SizedBox(height: 20),
            Text('Price: Rs ${item.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
          ],
        ),
      ),
    );
  }
}
