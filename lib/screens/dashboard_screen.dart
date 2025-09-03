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

  // THEME
  static const Color kCream = Color(0xFFF8F4F0);
  static const Color kChoco = Color(0xFF8B5E3C);
  static const double kRadius = 20;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .get();
    if (!mounted) return;
    setState(() => userName = (snap.data() ?? const {})['name'] ?? '');
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.lato(fontWeight: FontWeight.w700),
        ),
        content: Text('Do you want to logout?', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kChoco,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  // ======= GREETING HEADER (unchanged) =======
  Widget _greetingHeader() {
    // keep the same size and look as before
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      padding: const EdgeInsets.fromLTRB(30, 26, 30, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5E3C), Color(0xFF432B11)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white24),
            ),
            child: const Center(
              child: Text('👋', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) "Hi" on its own line
                Text(
                  'Hi',
                  style: GoogleFonts.lato(
                    fontSize: 30, // 2) title down from 35 -> 30
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                // 2) Name forced to single line (auto-shrinks instead of wrapping)
                if ((userName ?? '').isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        userName!,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                // untouched: same alignment/size as before
                Text(
                  "Welcome back! What do you want to do today?",
                  style: GoogleFonts.lato(fontSize: 22, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======= ACTION TILE (unchanged) =======
  Widget _actionTile({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(kRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ======= DRAWER (UPDATED to match admin layout) =======
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Big header area like admin
          const DrawerHeader(
            decoration: BoxDecoration(color: kChoco),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'FixItNow Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          // Added My Profile (new)
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),
          // Keep About Us, then Sign Out immediately after (like admin)
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
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  // ======= BUILD (unchanged) =======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kChoco),
        title: Text(
          'Dashboard',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kChoco,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: kChoco),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _greetingHeader()),
          SliverToBoxAdapter(
            child: _actionTile(
              title: 'My Complaints',
              icon: Icons.report_gmailerrorred_outlined,
              gradient: const [Color(0xFF7F5AF0), Color(0xFFB983FF)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _actionTile(
              title: 'File Complaint',
              icon: Icons.edit_note_rounded,
              gradient: const [Color(0xFFEF476F), Color(0xFFFF8FAB)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FileComplaintScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _actionTile(
              title: 'Announcements',
              icon: Icons.announcement_outlined,
              gradient: const [Color(0xFF06D6A0), Color(0xFF67EACA)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnnouncementScreen(userType: 'cr'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _actionTile(
              title: 'Complaint Stats',
              icon: Icons.bar_chart_rounded,
              gradient: const [Color(0xFF118AB2), Color(0xFF6CC1E1)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintStatsScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _actionTile(
              title: 'Notifications',
              icon: Icons.notifications_none_rounded,
              gradient: const [Color(0xFFFF7B00), Color(0xFFFFB36B)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
