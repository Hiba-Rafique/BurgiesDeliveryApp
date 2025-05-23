import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteMenuItemPage extends StatelessWidget {
  
  final String apiUrl = 'https://eliuwjh1sfjv.share.zrok.io/menu/delete'; 

  final nameController = TextEditingController();

  DeleteMenuItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Menu Item'),
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
                'Enter the name of the menu item to delete:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Menu Item Name TextField
              _buildTextField(
                controller: nameController,
                labelText: 'Menu Item Name',
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              // Delete Menu Item Button
              ElevatedButton(
                onPressed: () async {
  final itemName = nameController.text.trim();

  if (itemName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a name.')),
    );
    return;
  }

  final url = Uri.parse(apiUrl);

  try {
    final request = http.Request("DELETE", url)
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode({"name": itemName});

    final response = await http.Client().send(request);
    final statusCode = response.statusCode;

    if (statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item deleted successfully!')),
      );
      Navigator.pop(context);
    } else if (statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item not found.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed with status code: $statusCode')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
},

                child: const Center(child: Text('Delete')),
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
