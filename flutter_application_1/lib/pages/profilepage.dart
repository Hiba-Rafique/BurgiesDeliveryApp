import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('userSession');
    final String firstName = box.get('userFirstName', defaultValue: '');
    final String lastName = box.get('userLastName', defaultValue: '');
    final String email = box.get('userEmail', defaultValue: '');
    final String role = box.get('userRole', defaultValue: '');

    final String fullName = '$firstName $lastName';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: $fullName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: $email',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Role: $role',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Order History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual order data length
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long, color: Colors.amber),
                      title: Text('Order #${index + 1}'),
                      subtitle: const Text('Tap to view details'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Add order detail navigation
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
