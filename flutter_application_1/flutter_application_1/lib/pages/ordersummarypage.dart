import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'package:http/http.dart' as http;

class OrderSummaryPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final List<MenuItem> allMenuItems;

  final String userName;
  final String userPhone;
  final String userAddress;
  final int customerId;

  const OrderSummaryPage({
    super.key,
    required this.cartItems,
    required this.allMenuItems,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.customerId,
  });

  MenuItem getMenuItemById(int id) {
    return allMenuItems.firstWhere(
      (item) => item.id == id,
      orElse: () => MenuItem(
        id: -1,
        name: 'Unknown',
        description: '',
        imagePath: '',
        price: 0.0,
      ),
    );
  }

  Future<void> placeOrder(BuildContext context) async {
    final url = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/orders/place/$customerId');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (ctx) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Go to homepage
            });

            return AlertDialog(
              title: const Text('Order Confirmed'),
              content: Text(response.body),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to place order: ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserDetailRow('Name', userName),
                const SizedBox(height: 8),
                _buildUserDetailRow('Phone', userPhone),
                const SizedBox(height: 8),
                _buildUserDetailRow('Address', userAddress),
                const SizedBox(height: 12),
                _buildSimpleRow('Order Time', 'ASAP'),
                const SizedBox(height: 8),
                _buildSimpleRow('Pickup From', 'Burgies'),
              ],
            ),
          ),
          _buildInputField('Add order notes'),
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
              onPressed: () => placeOrder(context),
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

  Widget _buildUserDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: Colors.amber)),
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
