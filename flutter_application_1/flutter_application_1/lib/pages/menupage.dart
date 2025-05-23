import 'package:flutter/material.dart';
import 'package:flutter_application_1/drawer.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/pages/Menuitemdetailpage.dart';
import 'package:flutter_application_1/pages/cartpage.dart';
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> menuItems = [];
  List<CartItem> cartItems = [];
  int? customerId;  // <-- added to store customerId

  @override
  void initState() {
    super.initState();
    loadCustomerId();
    loadMenuItems();
    loadCart();
  }

  void loadCustomerId() {
    final box = Hive.box('userSession');  // or whatever box stores user info
    // Adjust key to your actual Hive key for customer id
    final id = box.get('customerId');
    // print(customerId);
    setState(() {
      customerId = id != null ? int.tryParse(id.toString()) : null;
    });
  }

  Future<void> loadMenuItems() async {
    final menuBox = Hive.box<MenuItem>('menuItemBox');

    try {
      final response = await http.get(Uri.parse('https://eliuwjh1sfjv.share.zrok.io/menu/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final items = data.map((item) => MenuItem.fromJson(item)).toList();

        await menuBox.clear();
        for (var item in items) {
          await menuBox.add(item);
        }

        setState(() {
          menuItems = items;
        });
        return;
      }
    } catch (e) {
      print('Error fetching from API: $e');
    }

    if (menuBox.isNotEmpty) {
      setState(() {
        menuItems = menuBox.values.toList();
      });
    }
  }

  void loadCart() {
    final box = Hive.box<CartItem>('cartBox');
    setState(() {
      cartItems = box.values.toList();
    });
  }

  void addToCart(MenuItem menuItem) {
    final box = Hive.box<CartItem>('cartBox');

    final existingIndex = cartItems.indexWhere((item) => item.menuItemId == menuItem.id);
    if (existingIndex != -1) {
      setState(() {
        cartItems[existingIndex].quantity += 1;
        box.putAt(existingIndex, cartItems[existingIndex]);
      });
    } else {
      final cartItem = CartItem(
        name: menuItem.name,
        menuItemId: menuItem.id,
        quantity: 1,
        price: menuItem.price,
        cartId: customerId ?? 1,  // use actual customerId or fallback
      );

      box.add(cartItem);
      setState(() {
        cartItems.add(cartItem);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${menuItem.name} added to cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            if (customerId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(
                    cartItems: cartItems,
                    allMenuItems: menuItems,
                    customerId: customerId!,
                  ),
                ),
              );
            } else {
              // Handle null customerId scenario if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer ID not found!')),
              );
            }
          },
        ),
      ),
    );

    sendToBackend(CartItem(
      name: menuItem.name,
      menuItemId: menuItem.id,
      quantity: 1,
      price: menuItem.price,
      cartId: customerId ?? 1,
    ));
  }

  Future<void> sendToBackend(CartItem cartItem) async {
  try {
    // Open the Hive box (usually done once, maybe in main() or initState)
    var userSessionBox = Hive.box('userSession'); 

    // Retrieve customerId from Hive box
    var customerId = userSessionBox.get('customerId');

    if (customerId == null) {
      print('No customerId found in userSession');
      return;
    }

    final response = await http.post(
      Uri.parse('https://eliuwjh1sfjv.share.zrok.io/cart-items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customerId': customerId,  // add customerId here
        'menuItemId': cartItem.menuItemId,
        'quantity': cartItem.quantity,
        
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to add item to backend: ${response.body}');
    } else {
      print('Item added successfully');
    }
  } catch (e) {
    print('Backend error: $e');
  }
}

  Widget _buildFoodCard(MenuItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MenuItemDetailPage(item: item)),
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            ListTile(
              leading: ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: (item.imagePath.startsWith('assets'))
      ? Image.asset(
          item.imagePath,
          width: 60,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60),
        )
      : Image.network(
          'https://eliuwjh1sfjv.share.zrok.io${item.imagePath}',  // Add your base URL if needed
          width: 60,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60),
        ),
),

              title: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rs ${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 30),
                    onPressed: () => addToCart(item),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amberAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              if (customerId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartPage(
                      cartItems: cartItems,
                      allMenuItems: menuItems,
                      customerId: customerId!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer ID not found!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: menuItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Loading Menu...",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: Text("Menu", style: GoogleFonts.bungee(fontSize: 30))),
                  ),
                  ...menuItems.map(_buildFoodCard).toList(),
                ],
              ),
            ),
    );
  }
}
