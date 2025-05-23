import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/SplashScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'package:flutter_application_1/models/cartitem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters for custom classes
  Hive.registerAdapter(MenuItemAdapter());
  Hive.registerAdapter(CartItemAdapter());

  // Open boxes only once at app startup
  await openBoxes();

  runApp(const MyApp());
}

Future<void> openBoxes() async {
  if (!Hive.isBoxOpen('userSession')) {
    await Hive.openBox('userSession');
  }
  if (!Hive.isBoxOpen('cartBox')) {
    await Hive.openBox<CartItem>('cartBox');
  }
  if (!Hive.isBoxOpen('menuItemBox')) {
    await Hive.openBox<MenuItem>('menuItemBox');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
          surface: Colors.amber,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
      ),
    );
  }
}
