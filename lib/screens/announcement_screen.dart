import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> announcementStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("📢 Announcements"),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: announcementStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No announcements available."));
          }

          final filtered = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final target = (data['target'] ?? '').toString().toUpperCase();
            return target == 'ALL' || target == 'CR';
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text("No relevant announcements."));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final data = filtered[index].data() as Map<String, dynamic>;
              final message = data['message'] ?? 'No message';
              final target = data['target'] ?? 'Unknown';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final timeString = timestamp != null
                  ? '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year} '
                      '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                  : 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Target: $target"),
                      Text("Posted on: $timeString"),
                    ],
                  ),
                  leading: const Icon(Icons.announcement, color: Colors.pink),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
