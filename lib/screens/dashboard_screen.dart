import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MyComplaintsScreen.dart';
import 'file_complaint_screen.dart';
import 'announcement_screen.dart';
import 'complaint_stats_screen.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'MyProfileScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;

  final Color backgroundColor = const Color(0xFFF8F4F0);
  final Color cardTextColor = const Color(0xFF6B5E5E);

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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.brown),
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: _buildDashboardContent(context, screenWidth),
    );
  }

  Widget _buildDashboardContent(BuildContext context, double screenWidth) {
    final List<List<dynamic>> items = [
      [
        "My Complaints",
        Icons.report_problem,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
        ),
      ],
      [
        "File Complaint",
        Icons.edit,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FileComplaintScreen()),
        ),
      ],
      [
        "Announcements",
        Icons.announcement,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AnnouncementScreen(userType: 'cr'),
          ),
        ),
      ],
      [
        "Complaint Stats",
        Icons.bar_chart,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComplaintStatsScreen()),
        ),
      ],
      [
        "Notifications",
        Icons.notifications,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationsScreen()),
        ),
      ],
    ];

    double aspectRatio = screenWidth < 360
        ? 0.8
        : screenWidth < 400
        ? 1
        : 1.1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi 👋 ${userName ?? ''}",
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B5E3C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Welcome back! What do you want to do today?",
            style: GoogleFonts.lato(fontSize: 16, color: cardTextColor),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildDashboardTile(item[1], item[0], item[2]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8B5E3C)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF8B5E3C)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: GoogleFonts.lato(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: cardTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF8B5E3C)),
            child: Text(
              'FixItNow Menu',
              style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}
