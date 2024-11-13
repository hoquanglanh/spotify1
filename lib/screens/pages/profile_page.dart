import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String email;

  const ProfilePage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 34, 34),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF42C83C),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Profile Info Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 45, 45, 45),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color.fromARGB(255, 82, 82, 82),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.person,
                      title: 'Name',
                      value: email.split('@')[0], // Using email username as name
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Sign Out Button
              ElevatedButton(
                onPressed: () {
                  // Handle sign out
                  Navigator.of(context).pushReplacementNamed('/signin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF42C83C),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0xFF42C83C),
          size: 24,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}