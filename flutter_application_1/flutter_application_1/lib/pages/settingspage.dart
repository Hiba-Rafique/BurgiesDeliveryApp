import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/EditProfilePage.dart' show EditProfilePage;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Payment Methods', style: TextStyle(color: Colors.amber)),
        content: const Text('Only Cash on Delivery is currently available.', style: TextStyle(color: Colors.amber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _goToContactInfo(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
  }

 void _goToEditProfile(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
}


  Widget _buildListTile(BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.amber,
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.amber,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildListTile(context, 'Payment Methods', 'Manage your payment methods', () => _showPaymentDialog(context)),
          const SizedBox(height: 12),

          _buildListTile(context, 'Edit Profile', 'Update your email and password', () => _goToEditProfile(context)),
          const SizedBox(height: 12),

          _buildListTile(context, 'Contact Info', 'Our phone, email, and locations', () => _goToContactInfo(context)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}


class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Info', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.amber,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.amber,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Burgies Contact Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 20),
                Text('Contact: 051 8893333', style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(height: 10),
                Text('Email: info@burgies.pk', style: TextStyle(fontSize: 16, color: Colors.black)),
                SizedBox(height: 20),
                Text(
                  'For more info, visit our website:\nhttps://burgies.pk/',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
