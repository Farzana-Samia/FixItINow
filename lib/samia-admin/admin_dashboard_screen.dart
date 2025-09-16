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
    const cream = Color(0xFFF8F4F0);
    const choco = Color(0xFF8B5E3C);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        foregroundColor: choco,
        title: Text(
          'Admin Panel',
          style: const TextStyle(
            color: choco,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            color: choco,
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: choco),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bigger chocolate greeting banner (CR-sized)
              const _WelcomeBannerLarge(),

              const SizedBox(height: 16),

              // Action tiles
              _ActionTile(
                title: 'Assign Complaints',
                icon: Icons.assignment,
                gradient: const [Color(0xFF7C4DFF), Color(0xFFB388FF)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AssignComplaintScreen(),
                  ),
                ),
              ),
              _ActionTile(
                title: 'Manage Teams',
                icon: Icons.groups_2,
                gradient: const [Color(0xFFFF6F91), Color(0xFFFF8E53)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageTeamsScreen()),
                ),
              ),
              _ActionTile(
                title: 'CR List',
                icon: Icons.list_alt_rounded,
                gradient: const [Color(0xFFFFB300), Color(0xFFFFD54F)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCRListScreen()),
                ),
              ),
              _ActionTile(
                title: 'Announcement',
                icon: Icons.announcement,
                gradient: const [Color(0xFF00C6A7), Color(0xFF1DE9B6)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementScreen(
                      userType: 'admin',
                      teamType: null,
                    ),
                  ),
                ),
              ),
              _ActionTile(
                title: 'CR Rep Sessions',
                icon: Icons.person_search,
                gradient: const [Color(0xFF5C6BC0), Color(0xFF8E99F3)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuestSessionScreen()),
                ),
              ),
              _ActionTile(
                title: 'Summary',
                icon: Icons.dashboard_customize,
                gradient: const [Color(0xFF29B6F6), Color(0xFF81D4FA)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminSummaryScreen()),
                ),
              ),
              _ActionTile(
                title: 'Recheck Requests',
                icon: Icons.replay,
                gradient: const [Color(0xFFFF7043), Color(0xFFFFA270)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminRecheckScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big chocolate banner — sized like the CR tile you shared.
class _WelcomeBannerLarge extends StatelessWidget {
  const _WelcomeBannerLarge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5E3C), Color(0xFF432B11)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar circle with emoji
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: const Text('👋', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          // texts
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome back! What do you want to do today?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
