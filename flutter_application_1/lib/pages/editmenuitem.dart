import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMenuItemPage extends StatelessWidget {
  final String itemName;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final String apiUrl = 'https://eliuwjh1sfjv.share.zrok.io/menu/edit';

  EditMenuItemPage({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Menu Item Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Name TextField
              _buildTextField(
                controller: nameController,
                labelText: 'Name',
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              // Description TextField
              _buildTextField(
                controller: descriptionController,
                labelText: 'Description',
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              // Price TextField
              _buildTextField(
                controller: priceController,
                labelText: 'Price',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Update Button
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields.')),
                    );
                    return;
                  }

                  final response = await http.put(
                    Uri.parse('$apiUrl/$itemName'),
                    headers: <String, String>{
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'price': double.parse(priceController.text),
                    }),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu item updated successfully!')),
                    );
                    Navigator.pop(context); // Go back to Admin Page
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update menu item.')),
                    );
                  }
                },
                child: Center(child: const Text('Update')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType inputType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      ),
      keyboardType: inputType,
    );
  }
}
