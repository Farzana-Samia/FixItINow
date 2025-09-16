import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contact_us.dart';
import 'about_us.dart';
import 'login_screen.dart';
import 'team_notifications_screen.dart';
import 'team_announcement_screen.dart';
import 'team_complaint_stats_screen.dart';
import 'team_complaint_list_inline.dart';

class TeamDashboardScreen extends StatefulWidget {
  final String teamName;

  const TeamDashboardScreen({super.key, required this.teamName});

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  bool hasUnseenNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnseenNotifications();
  }

  Future<void> checkUnseenNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: widget.teamName)
        .where('seen', isEqualTo: false)
        .get();

    setState(() {
      hasUnseenNotifications = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Widget buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
    bool showRedDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (showRedDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} Team Dashboard'),
        backgroundColor: const Color(0xFF8B5E3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _confirmAndLogout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF8B5E3C)),
              child: Text(
                'FixItNow Menu',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: _confirmAndLogout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            buildDashboardCard(
              context: context,
              title: 'Complaints',
              icon: Icons.build,
              startColor: Colors.teal,
              endColor: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeamComplaintListInline(teamName: widget.teamName),
                  ),
                );
              },
            ),
            buildDashboardCard(
              context: context,
              title: 'Announcements',
              icon: Icons.announcement,
              startColor: Colors.blue,
              endColor: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeamAnnouncementScreen(teamName: widget.teamName),
                  ),
                );
              },
            ),
            buildDashboardCard(
              context: context,
              title: 'Notifications',
              icon: Icons.notifications,
              startColor: Colors.deepOrange,
              endColor: Colors.pink,
              showRedDot: hasUnseenNotifications,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeamNotificationsScreen(teamName: widget.teamName),
                  ),
                ).then((_) => checkUnseenNotifications());
              },
            ),
            buildDashboardCard(
              context: context,
              title: 'Complaint Stats',
              icon: Icons.bar_chart,
              startColor: Colors.purple,
              endColor: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TeamComplaintStatsScreen(teamName: widget.teamName),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}