import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Coordinates for Burgies locations
    final LatLng _location1 = LatLng(33.5284427533631, 73.11210957108183);  // Location 1
    final LatLng _location2 = LatLng(33.49383788042002, 73.09853727925012); // Location 2

    // Markers for locations
    final Set<Marker> _markers = {
      Marker(
        markerId: MarkerId('location1'),
        position: _location1,
        infoWindow: InfoWindow(title: 'Burgies Location 1'),
      ),
      Marker(
        markerId: MarkerId('location2'),
        position: _location2,
        infoWindow: InfoWindow(title: 'Burgies Location 2'),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.amber,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Burgies',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            const Text(
              'Burgies is a fast food company with locations in multiple cities. We pride ourselves on serving delicious burgers and fast food in a friendly environment.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
