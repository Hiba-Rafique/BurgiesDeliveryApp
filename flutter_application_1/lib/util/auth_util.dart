import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/loginpage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_application_1/models/cartitem.dart';

Future<void> logout(BuildContext context) async {
  final box = Hive.box('userSession');
  final cartBox = Hive.box<CartItem>('cartBox');
  await cartBox.clear(); // Clear cart on logout
  await box.put('userLoggedIn', false);
  
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage()),
    (_) => false,
  );
}
