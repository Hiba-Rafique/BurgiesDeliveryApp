import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class AddMenuItemPage extends StatefulWidget {
  @override
  _AddMenuItemPageState createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String? _imagePath;  // Store the image path

  final String apiUrl = 'https://eliuwjh1sfjv.share.zrok.io/menu/add'; 

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;  // Save the path of the image
      });
    }
  }

 Future<void> _uploadMenuItem() async {
  if (_imagePath == null ||
      nameController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      priceController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields and select an image.')),
    );
    return;
  }

  var uri = Uri.parse(apiUrl);
  var request = http.MultipartRequest('POST', uri);

  // Attach the image file
  request.files.add(
    await http.MultipartFile.fromPath('image', _imagePath!),
  );

  // Add text fields
  request.fields['name'] = nameController.text;
  request.fields['description'] = descriptionController.text;
  request.fields['price'] = priceController.text;

  try {
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu item added successfully!')),
      );
      Navigator.pop(context); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed with status: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error occurred: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
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
                'Menu Item Details',
                style: TextStyle(
                  fontSize: 22,
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
              const SizedBox(height: 15),
              // Description TextField
              _buildTextField(
                controller: descriptionController,
                labelText: 'Description',
                inputType: TextInputType.text,
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              // Price TextField
              _buildTextField(
                controller: priceController,
                labelText: 'Price',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Pick Image Button
              ElevatedButton(
  onPressed: _pickImage,
  child: Center(child: const Text('Pick Image')),
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
if (_imagePath != null)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Image:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Image.file(
          File(_imagePath!),
          height: 150,
          fit: BoxFit.cover,
        ),
      ],
    ),
  ),
const SizedBox(height: 20),

              // Add Menu Item Button
              ElevatedButton(
                onPressed: _uploadMenuItem,
                child: Center(child: const Text('Add')),
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
    int maxLines = 1,
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
      maxLines: maxLines,
    );
  }
}
