import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assign_complaint_screen.dart';
import 'manage_teams_screen.dart';
import 'admin_cr_list_screen.dart';
import 'package:fixitnow/screens/announcement_screen.dart';
import 'package:fixitnow/screens/guest_session_screen.dart';
import 'admin_summary_screen.dart';
import 'admin_recheck_screen.dart';
import 'package:fixitnow/screens/contact_us.dart';
import 'package:fixitnow/screens/about_us.dart';
import 'package:fixitnow/screens/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Do you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <_AdminItem>[
      _AdminItem(
        title: 'Assign Complaints',
        icon: Icons.assignment,
        color: Colors.purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssignComplaintScreen()),
        ),
      ),
      _AdminItem(
        title: 'Manage Teams',
        icon: Icons.groups_2,
        color: Colors.pink,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ManageTeamsScreen()),
        ),
      ),
      _AdminItem(
        title: 'CR List',
        icon: Icons.list,
        color: Colors.orange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminCRListScreen()),
        ),
      ),
      _AdminItem(
        title: 'Announcement',
        icon: Icons.announcement,
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AnnouncementScreen(userType: 'admin', teamType: null),
          ),
        ),
      ),
      _AdminItem(
        title: 'CR Rep Sessions',
        icon: Icons.person_search,
        color: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuestSessionScreen()),
        ),
      ),
      _AdminItem(
        title: 'Summary',
        icon: Icons.dashboard_customize,
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminSummaryScreen()),
        ),
      ),
      _AdminItem(
        title: 'Recheck Requests',
        icon: Icons.replay,
        color: Colors.deepOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminRecheckScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.pink[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
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
              leading: const Icon(Icons.info),
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
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Force two columns on phones; 3 on larger screens
          final crossAxisCount = constraints.maxWidth < 900 ? 2 : 3;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, // keep cards square-ish
            ),
            itemBuilder: (context, i) => _DashboardCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _AdminItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _AdminItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _DashboardCard extends StatelessWidget {
  final _AdminItem item;
  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [item.color.withOpacity(0.6), item.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 40, color: Colors.white),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
