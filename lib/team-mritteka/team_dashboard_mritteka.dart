import 'package:flutter/material.dart';
import 'complaint_electrician_mritteka.dart';
import 'priority_mritteka.dart';
import 'notification_mritteka.dart';
import 'history_mritteka.dart';
    // Adjust the path as per your project structure

// Other pages remain the same...

class TeamDashboardMritteka extends StatelessWidget {
  const TeamDashboardMritteka({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Electrician Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () {
              Navigator.pop(context); // Or navigate to login page
            },
          ),
        ],
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
              const ComplaintElectricianMritteka(),  // Use the imported page here
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
