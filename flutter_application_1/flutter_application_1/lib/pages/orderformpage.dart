import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:flutter_application_1/models/cartitem.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'package:flutter_application_1/pages/ordersummarypage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderFormPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final List<MenuItem> allMenuItems;

  const OrderFormPage({
    super.key,
    required this.cartItems,
    required this.allMenuItems,
  });

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetailsFromHive();
  }

  void _loadUserDetailsFromHive() async {
    var box = await Hive.openBox('userSession');
    final firstName = box.get('userFirstName');
    final lastName = box.get('userLastName');
    final mobile = box.get('userPhone');
    final address = box.get('userAddress');

    if (firstName != null || lastName != null) {
      final fullName = ((firstName ?? '') + ' ' + (lastName ?? '')).trim();
      if (fullName.isNotEmpty) nameController.text = fullName;
    }
    if (mobile != null) mobileController.text = mobile;
    if (address != null) addressController.text = address;
  }

  Future<void> submitOrder() async {
    if (_formKey.currentState!.validate()) {
      var box = Hive.box('userSession');
      final fullName = nameController.text.trim();
      final mobile = mobileController.text.trim();
      final address = addressController.text.trim();

      final customerId = box.get('customerId');

      if (customerId == null) {
        // Handle missing customerId
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer ID not found. Please log in again.')),
        );
        return;
      }

      // PUT request to update address
      final url = Uri.parse('https://eliuwjh1sfjv.share.zrok.io/customers/$customerId/address');
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body:address, 
        );

        if (response.statusCode == 200) {
          // Save locally in Hive only if server update successful
          box.put('userFullName', fullName);
          box.put('userMobile', mobile);
          box.put('userAddress', address);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSummaryPage(
                cartItems: widget.cartItems,
                allMenuItems: widget.allMenuItems,
                userName: fullName,
                userPhone: mobile,
                userAddress: address,
                customerId: customerId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update address: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Delivery Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.length != 11
                    ? 'Enter a valid 11-digit mobile number'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your address' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'Confirm Order',
                    style: TextStyle(color: Colors.amber, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
