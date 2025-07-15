import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MyComplaintsScreen.dart';
import 'file_complaint_screen.dart';
import 'MyProfileScreen.dart';
import 'announcement_screen.dart';
import 'complaint_stats_screen.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        userName = data?['name'] ?? '';
      });
    }
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink),
              child: Text(
                'FixItNow Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, 👋 ${userName ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard("My Complaints", Icons.report, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyComplaintsScreen(),
                      ),
                    );
                  }, Colors.purple),
                  _buildCard("File Complaint", Icons.edit, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FileComplaintScreen(),
                      ),
                    );
                  }, Colors.pink),
                  _buildCard("Announcements", Icons.announcement, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnnouncementScreen(),
                      ),
                    );
                  }, Colors.orange),
                  _buildCard("My Profile", Icons.person, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyProfileScreen(),
                      ),
                    );
                  }, Colors.teal),
                  _buildCard(
                    "Complaint Stats",
                    Icons.bar_chart,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComplaintStatsScreen(),
                        ),
                      );
                    },
                    const Color.fromARGB(255, 48, 191, 235),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
