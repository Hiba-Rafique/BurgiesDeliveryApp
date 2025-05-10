import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.amber,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const ListTile(
            title: Text('Payment Methods'),
            subtitle: Text('Manage your payment methods'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            title: Text('Addresses'),
            subtitle: Text('Edit or add delivery locations'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            title: Text('Help & Support'),
            subtitle: Text('FAQs, contact support, and more'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const ListTile(
            title: Text('Terms & Privacy Policy'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
