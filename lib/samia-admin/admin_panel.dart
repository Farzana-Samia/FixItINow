import 'package:flutter/material.dart';
import 'login_page.dart';
import 'assign_complaints_page.dart';
import 'manage_teams_page.dart';
import 'manage_announcements_page.dart';
import 'cr_list_page.dart';
import 'guest_sessions_page.dart';
import 'admin_summary_page.dart';


class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        // AppBarTheme in main.dart handles the background and foreground colors.
        automaticallyImplyLeading: false, // Hide default back button
        leading: Builder( // Use Builder to get a context that can open the Scaffold's drawer
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Hamburger icon for drawer
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Opens the drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer( // The Drawer widget
        child: ListView(
          padding: EdgeInsets.zero, // Remove default padding
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink, // Drawer header background color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Admin Panel Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // FIX: Removed navigation logic. Now it just closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // FIX: Removed navigation logic. Now it just closes the drawer.
              },
            ),
            // You can add more ListTiles here for other drawer items
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            _buildAdminPanelCard(
              context,
              icon: Icons.assignment,
              title: 'Assign Complaints',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssignComplaintsPage()),
                );
              },
            ),
            _buildAdminPanelCard(
              context,
              icon: Icons.people,
              title: 'Manage Teams',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageTeamsPage()),
                );
              },
            ),
            _buildAdminPanelCard(
              context,
              icon: Icons.list,
              title: 'CR List',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CRListPage()),
                );
              },
            ),
            _buildAdminPanelCard(
              context,
              icon: Icons.announcement,
              title: 'Announcements',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageAnnouncementsPage()),
                );
              },
            ),
            _buildAdminPanelCard(
              context,
              icon: Icons.lock_open,
              title: 'Guest Sessions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuestSessionsPage()),
                );
              },
            ),
            _buildAdminPanelCard(
              context,
              icon: Icons.bar_chart,
              title: 'Summary',
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminSummaryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPanelCard(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.pink[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 50,
              color: Colors.pink,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}