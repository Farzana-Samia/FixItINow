import 'package:flutter/material.dart';
import 'complaint_electrician_mritteka.dart';

import 'announcement-team-page.dart';
import 'notification_mritteka.dart';
import 'project-team-stats.dart';
import 'log_in_team_mritteka.dart';
import 'package:flutter_fix_it_now/profile_team.dart'; // Ensure ProfilePage exists

class TeamDashboardMritteka extends StatelessWidget {
  final String userName;

  const TeamDashboardMritteka({super.key, required this.userName});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple.shade50,
          title: const Text(
            'Are you sure?',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Do you want to log out?',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  LogInTeamMritteka()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, $userName',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Fix It Now',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Complaint'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ComplaintElectricianMritteka()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),

              title: const Text('Announcements'),
              onTap: () {

                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AnnouncementPage()));

                Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementPage()));

              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
 
              title: const Text('Notifications'),

              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),

              title: const Text('Complaint History'),
              onTap: () {

                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProjectorTeamStatsPage()));

                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectorTeamStatsPage()));


              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGridItem(
              context,
              'Complaint',
              Icons.report_problem,
              Colors.orange,
              const ComplaintElectricianMritteka(),
            ),
            _buildGridItem(
              context,
              ' Announcements',
              Icons.warning_amber,
              Colors.redAccent,
              const AnnouncementPage(),
            ),
            _buildGridItem(
              context,
              'Notifications',

              Icons.notifications,
              Colors.blue,
              const NotificationPage(),
            ),
            _buildGridItem(
              context,
              'Complaint History',
              Icons.history,
              Colors.green,
              const ProjectorTeamStatsPage(),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
