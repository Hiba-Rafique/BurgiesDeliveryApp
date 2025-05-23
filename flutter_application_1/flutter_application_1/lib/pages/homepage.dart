import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/drawer.dart';
import 'package:flutter_application_1/models/menuitem.dart';
import 'package:flutter_application_1/pages/cartpage.dart';
import 'package:flutter_application_1/pages/Menuitemdetailpage.dart'; // <-- your detail page
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController pageController = PageController(viewportFraction: 0.9);
  late Timer _timer;
  final int _totalItems = 4;

  List<MenuItem> allMenuItems = [];
  List<MenuItem> featuredItems = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), _autoScroll);
    loadMenuItems();
  }

  void _autoScroll(Timer timer) {
    if (pageController.hasClients) {
      if (pageController.page?.toInt() == _totalItems - 1) {
        pageController.jumpToPage(0);
      } else {
        pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    }
  }

  Future<void> loadMenuItems() async {
    final menuBox = Hive.box<MenuItem>('menuItemBox');

    try {
      final response = await http.get(Uri.parse('https://eliuwjh1sfjv.share.zrok.io/menu/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final items = data.map((item) => MenuItem.fromJson(item)).toList();

        await menuBox.clear();
        for (var item in items) {
          await menuBox.add(item);
        }

        setState(() {
          allMenuItems = items;
          featuredItems = _getRandomFeaturedItems(items, 3); // 3 featured items
        });
        return;
      }
    } catch (e) {
      print('Error fetching from API: $e');
    }

    if (menuBox.isNotEmpty) {
      final cachedItems = menuBox.values.toList();
      setState(() {
        allMenuItems = cachedItems;
        featuredItems = _getRandomFeaturedItems(cachedItems, 3);
      });
    }
  }

  List<MenuItem> _getRandomFeaturedItems(List<MenuItem> items, int count) {
    final random = Random();
    final List<MenuItem> shuffled = List<MenuItem>.from(items)..shuffle(random);
    return shuffled.take(count).toList();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _goToCartPage() async {
    var box = Hive.box('userSession');
    int? customerId = box.get('customerId');

    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer ID not found. Please login.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          customerId: customerId,
          allMenuItems: allMenuItems,
          cartItems: [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.amber),
            onPressed: _goToCartPage,
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              width: 200,
              height: 120,
              child: Image.asset('assets/burgieslogo.png', width: 150, height: 120),
            ),
          ),
          Text(
            "Hot Deals",
            style: GoogleFonts.poppins(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: pageController,
              itemCount: _totalItems,
              itemBuilder: (_, index) {
                String imagePath = 'assets/deal${index + 1}.png';
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Featured",
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
SizedBox(
  height: 100,
  child: featuredItems.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: featuredItems.length,
          itemBuilder: (context, index) {
            final item = featuredItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuItemDetailPage(item: item),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: item.imagePath.startsWith('assets')
                              ? AssetImage(item.imagePath) as ImageProvider
                              : NetworkImage('https://eliuwjh1sfjv.share.zrok.io'+item.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          color: Colors.amberAccent,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
),

        ],
      ),
    );
  }
}
