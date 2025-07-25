import 'package:flutter/material.dart';
import 'complaint_electrician_mritteka.dart';
import 'priority_mritteka.dart';
import 'notification_mritteka.dart';
import 'history_mritteka.dart';
import 'log_in_team_mritteka.dart';

class TeamDashboardMritteka extends StatelessWidget {
  const TeamDashboardMritteka({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin DashBoard for Electrician',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogInTeamMritteka()),
              );
            },
          ),
        ],
      ),


      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),

                child: Text(
                  'Fix It Now',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              
            ),
            ListTile(
              leading: const Icon(Icons.report_problem),
              title: const Text('Complaint'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintElectricianMritteka()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Priority Complaint'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PriorityComplaintPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LogInTeamMritteka()),
                );
              },
            ),
          ],
        ),
      ),

      // Your original grid view stays unchanged
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
              'Priority Complaint',
              Icons.warning_amber,
              Colors.redAccent,
              const PriorityComplaintPage(),
            ),
            _buildGridItem(
              context,
              'Notification',
              Icons.notifications,
              Colors.blue,
              const NotificationPage(),
            ),
            _buildGridItem(
              context,
              'History',
              Icons.history,
              Colors.green,
              const HistoryPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color color, Widget page) {
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
