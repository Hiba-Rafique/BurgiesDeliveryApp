import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/aboutpage.dart';
import 'package:flutter_application_1/pages/adminpage.dart';
import 'package:flutter_application_1/pages/homepage.dart';
import 'package:flutter_application_1/pages/menupage.dart';
import 'package:flutter_application_1/pages/profilepage.dart';
import 'package:flutter_application_1/pages/settingspage.dart';
import 'package:flutter_application_1/util/auth_util.dart';
import 'package:hive/hive.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7, 
      child: FutureBuilder(
        future: Hive.openBox('userSession'),  // Open the Hive box for user data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var box = Hive.box('userSession');
          var role = box.get('userRole');  

          return Container(
            color: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(45.0),
                  child: Image.asset('assets/burgieslogo.png', width: 150, height: 120),
                ),
               
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.amberAccent),
                  title: const Text('Home', style: TextStyle(color: Colors.amberAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                  },
                ),
               
                // Display Admin Dashboard if role is 'ADMIN' and Profile if it is 'CUSTOMER'
                if (role == 'ADMIN')
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.amberAccent),
                    title: const Text('Admin Dashboard', style: TextStyle(color: Colors.amberAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
                    },
                  ),
                
                if (role != 'ADMIN')
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.amberAccent),
                    title: const Text('Profile', style: TextStyle(color: Colors.amberAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    },
                  ),
               
                ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.amberAccent),
                  title: const Text('Menu', style: TextStyle(color: Colors.amberAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
                  },
                ),
               
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.amberAccent),
                  title: const Text('Settings', style: TextStyle(color: Colors.amberAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                  },
                ),
               
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.amberAccent),
                  title: const Text('About', style: TextStyle(color: Colors.amberAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.amberAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.amberAccent)),
                  onTap: () {
                    logout(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
