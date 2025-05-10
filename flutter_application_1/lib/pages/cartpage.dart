import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'orderformpage.dart'; 


class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final List<MenuItem> allMenuItems;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.allMenuItems,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

  void increaseQuantity(CartItem item) {
    setState(() {
      item.quantity += 1;
    });
  }

  void decreaseQuantity(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity -= 1;
      } else {
        widget.cartItems.remove(item); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(0, (sum, cartItem) {
      var menuItem = getMenuItemById(cartItem.menuItemId);
      return sum + (menuItem!.price * cartItem.quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty!",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                var cartItem = widget.cartItems[index];
                var menuItem = getMenuItemById(cartItem.menuItemId);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                              onPressed: () => decreaseQuantity(cartItem),
                            ),
                            Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => increaseQuantity(cartItem),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.cartItems.isNotEmpty
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
    MaterialPageRoute(builder: (context) => const OrderFormPage(allMenuItems: [], cartItems: [],)),
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
