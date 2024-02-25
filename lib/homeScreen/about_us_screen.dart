import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Our App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'UOBER: Carpooling App, a game-changing ride-sharing application catering exclusively to University of Bahrain students facing transportation hurdles while residing in close proximity. UOBER provides an innovative solution by connecting students who lack personal transportation with fellow students who own vehicles and share the same location, offering affordable rides to and from the university.',
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Email: Uober@gmail.com'),
            Text('Phone: +973-17762121'),
          ],
        ),
      ),
    );
  }
}
