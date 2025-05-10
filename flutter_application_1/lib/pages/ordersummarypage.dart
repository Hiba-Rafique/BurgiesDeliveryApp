import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/models/menuitem.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final List<MenuItem> allMenuItems;

  const OrderSummaryPage({
    super.key,
    required this.cartItems,
    required this.allMenuItems,
  });

  MenuItem getMenuItemById(int id) {
    return allMenuItems.firstWhere(
      (item) => item.id == id,
      orElse: () => MenuItem(id: -1, name: 'Unknown', description: '', imagePath: '', price: 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = cartItems.fold(0, (sum, cartItem) {
      final item = getMenuItemById(cartItem.menuItemId);
      return sum + (item.price * cartItem.quantity);
    });

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Order Summary',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildRow('Order Time', 'ASAP', context),
                const SizedBox(height: 12),
                _buildRow('Pickup From', 'Burgies', context),
              ],
            ),
          ),
          _buildInputField('Add order notes'),
          _buildInputField('Add promotion'),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ...cartItems.map((cartItem) {
                    final item = getMenuItemById(cartItem.menuItemId);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildPriceRow('${item.name}', item.price * cartItem.quantity),
                    );
                  }),
                  const Divider(color: Colors.amber),
                  _buildPriceRow('Subtotal', subtotal),
                  const SizedBox(height: 4),
                  _buildPriceRow('Total', subtotal, isBold: true),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Order Confirmed'),
                    content: const Text('Your order has been placed!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Complete Order   \Rs${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16, color: Colors.amber)),
        ]),
        Text('Change', style: TextStyle(color: Colors.amber[200]))
      ],
    );
  }

  Widget _buildInputField(String hint) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: Colors.amber,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
        Text('\Rs${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }
}
