import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class OrderSummaryPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderSummaryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>? ?? [];
    final orderId = order['orderId'] ?? 'N/A';

    double totalCost = 0;
    for (var item in items) {
      final menuItem = item['menuItem'];
      final price = (menuItem != null && menuItem['price'] != null)
          ? (menuItem['price'] as num).toDouble()
          : 0.0;
      final quantity = (item['quantity'] ?? 0) as int;
      totalCost += price * quantity;
    }

    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Text(
          'Order Summary #$orderId',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final menuItem = item['menuItem'];
                  final name = menuItem?['name'] ?? 'Unknown item';
                  final quantity = item['quantity'] ?? 0;
                  final price = (menuItem != null && menuItem['price'] != null)
                      ? (menuItem['price'] as num).toDouble()
                      : 0.0;
                  final itemTotal = price * quantity;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: $quantity',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Text(
                        'Rs ${itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    'Rs ${totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> orderHistory = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    final box = Hive.box('userSession');
    final customerId = box.get('customerId');

    if (customerId == null) {
      setState(() {
        errorMessage = 'Customer ID not found. Please log in again.';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/orders/history/$customerId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is String) {
            orderHistory = [];
            errorMessage = data;
          } else if (data is List) {
            orderHistory = data;
            errorMessage = null;
          } else {
            errorMessage = 'Unexpected data format from server';
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load order history: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading order history: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('userSession');
    final String fullName = '${box.get('userFirstName', defaultValue: '')} ${box.get('userLastName', defaultValue: '')}'.trim();
    final String email = box.get('userEmail', defaultValue: '');
    final String role = box.get('userRole', defaultValue: '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text(role, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Order History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              )
            else if (orderHistory.isEmpty)
              const Center(child: Text('No orders found'))
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderHistory.length,
                itemBuilder: (context, index) {
                  final order = orderHistory[index];
                  final orderId = order['orderId'] ?? 'N/A';
                  final orderDate = (order['date']?.toString().split('T')[0]) ?? 'Unknown date';
                  final orderStatus = order['status'] ?? 'Unknown status';

                  final items = order['items'] as List<dynamic>? ?? [];
                  final itemNames = items.map((item) {
                    final menuItem = item['menuItem'];
                    return menuItem != null ? menuItem['name'] ?? '' : '';
                  }).where((name) => name.isNotEmpty).join(', ');

                  double totalCost = 0.0;
                  for (var item in items) {
                    final menuItem = item['menuItem'];
                    final price = (menuItem != null && menuItem['price'] != null)
                        ? (menuItem['price'] as num).toDouble()
                        : 0.0;
                    final quantity = (item['quantity'] ?? 0) as int;
                    totalCost += price * quantity;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                'Order #$orderId',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: $orderDate\n'
                            'Status: $orderStatus\n'
                            'Items: $itemNames\n'
                            'Total: Rs ${totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderSummaryPage(order: order),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.amber),
                                ),
                              ),
                              icon: const Icon(Icons.info_outline),
                              label: const Text(
                                'View Summary',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
