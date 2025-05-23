import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'orderformpage.dart';

// Replace with your actual zrok backend base URL
const String baseUrl = 'https://eliuwjh1sfjv.share.zrok.io';

class CartPage extends StatefulWidget {
  final int customerId;
  final List<MenuItem> allMenuItems;

  const CartPage({
    super.key,
    required this.customerId,
    required this.allMenuItems,
    required List cartItems,  // keep this as you wrote it (even though unused here)
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  // Helper to get MenuItem by id
  MenuItem? getMenuItemById(int id) {
    return widget.allMenuItems.firstWhere(
      (item) => item.id == id,
      orElse: () => MenuItem(
        id: -1,
        name: 'Unknown',
        description: " ",
        imagePath: '',
        price: 0.0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/cart/${widget.customerId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonMap['cartItems'];

        setState(() {
          cartItems = jsonList.map((json) => CartItem.fromJson(json)).toList();
        });
      } else {
        setState(() {
          cartItems = [];
        });
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() {
        cartItems = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateCartItemQuantity(CartItem item, int change) async {
    int newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      await removeCartItem(item);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': widget.customerId,
          'menuItemId': item.menuItemId,
          'quantity': change,  // send the delta quantity, positive or negative
        }),
      );

      if (response.statusCode == 200) {
        await fetchCartItems(); // refresh cart items after update
      } else {
        print('Failed to update cart item: ${response.body}');
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  Future<void> removeCartItem(CartItem item) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart-items/${item.id}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((ci) => ci.id == item.id);
        });
      } else {
        print('Failed to delete cart item: ${response.body}');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(0, (sum, cartItem) {
      var menuItem = getMenuItemById(cartItem.menuItemId);
      return sum + (menuItem!.price * cartItem.quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    "Your cart is empty!",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index];
                    var menuItem = getMenuItemById(cartItem.menuItemId);

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: menuItem!.imagePath.isNotEmpty
                              ? Image.asset(
                                  menuItem.imagePath,
                                  width: 60,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.fastfood, size: 60);
                                  },
                                )
                              : const Icon(Icons.fastfood, size: 60),
                        ),
                        title: Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price: \Rs${(menuItem.price * cartItem.quantity).toStringAsFixed(2)}",
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      updateCartItemQuantity(cartItem, -1),
                                ),
                                Text('${cartItem.quantity}',
                                    style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      updateCartItemQuantity(cartItem, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: \Rs${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderFormPage(
                              cartItems: cartItems,
                              allMenuItems: widget.allMenuItems,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      child: const Text(
                        "Place Order",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
