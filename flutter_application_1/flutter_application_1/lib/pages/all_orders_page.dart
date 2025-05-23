import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;

  final String baseUrl = 'https://eliuwjh1sfjv.share.zrok.io';

  @override
  void initState() {
    super.initState();
    fetchActiveOrders();
  }

  Future<void> fetchActiveOrders() async {
    final url = Uri.parse('$baseUrl/orders/incomplete');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            orders = data;
            isLoading = false;
            errorMessage = null;
          });
        } else if (data is String) {
          setState(() {
            errorMessage = data;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch orders: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching orders: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Orders'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : orders.isEmpty
                    ? const Center(child: Text('No active orders found'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];

                          final orderId = order['orderId'] ?? 'N/A';
                          final dateRaw = order['date']?.toString() ?? '';
                          final orderDate =
                              dateRaw.isNotEmpty ? dateRaw.split('T')[0] : 'Unknown date';
                          final status = order['status'] ?? 'Unknown';

                          final customer = (order['customer'] != null && order['customer'] is Map)
                              ? Map<String, dynamic>.from(order['customer'])
                              : <String, dynamic>{};

                          final customerName =
                              ((customer['firstName'] ?? '') + ' ' + (customer['lastName'] ?? '')).trim();
                          final customerEmail = customer['email'] ?? 'No email';
                          final customerPhone = customer['phoneNumber'] ?? 'No phone';

                          final items = order['items'] as List<dynamic>? ?? [];

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
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #$orderId',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: $orderDate',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Status: $status',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const Divider(color: Colors.amber),
                                  Text(
                                    'Customer: $customerName',
                                    style: const TextStyle(
                                        color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Email: $customerEmail',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  Text(
                                    'Phone: $customerPhone',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Items:',
                                    style: TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // New widget to list items with quantities
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: items.map<Widget>((item) {
                                      final menuItem = item['menuItem'];
                                      final name = menuItem != null ? menuItem['name'] ?? '' : '';
                                      final quantity = item['quantity'] ?? 0;
                                      return Text(
                                        '$name x $quantity',
                                        style: const TextStyle(color: Colors.white70),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Cost: \Rs ${totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.amber, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
