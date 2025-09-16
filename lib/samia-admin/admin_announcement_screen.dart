import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAnnouncementScreen extends StatelessWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
<<<<<<< HEAD


=======
>>>>>>> 3efc857d6e73c6af336db082b9f1de6181b70062
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Announcements"),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: announcementStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data!.docs;

          if (announcements.isEmpty) {
            return const Center(child: Text("No announcements found."));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final data = announcements[index].data() as Map<String, dynamic>;

              final message = data['message'] ?? 'No message';
              final target = data['target'] ?? 'ALL';
              final expired = data['expired'] ?? false;
              final timestamp = data['timestamp'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(message),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Target: $target"),
                      if (timestamp != null)
                        Text(
                          "Posted: ${timestamp.toDate().toString().split('.').first}",
                        ),
                      if (expired == true)
                        const Text(
                          "❌ Expired",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
