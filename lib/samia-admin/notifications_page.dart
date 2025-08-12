import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final List<String> notifications = const [
    "New complaint reported: Projector in Room 101",
    "Furniture issue resolved in Room 203",
    "Light flicker issue assigned to Electric team",
    "Monthly report generated",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final cardColor = index % 2 == 0 ? Colors.pink[100] : Colors.pink[50];

          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.pink),
              title: Text(
                notifications[index],
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          );
        },
      ),
    );
  }
}
