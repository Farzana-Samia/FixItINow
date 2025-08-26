import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamNotificationsScreen extends StatelessWidget {
  final String teamName;

  const TeamNotificationsScreen({super.key, required this.teamName});

  Future<void> _markAsSeen(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'seen': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Notifications'),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: teamName)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final message = data['message'] ?? 'No message';
              final timestamp = data['timestamp']?.toDate();
              final seen = data['seen'] == true;

              return Card(
                elevation: 2,
                color: seen ? Colors.white : const Color(0xFFFFF9C4),
                child: ListTile(
                  title: Text(message),
                  subtitle: Text(
                    timestamp != null
                        ? timestamp.toString().substring(0, 19)
                        : 'Unknown time',
                  ),
                  trailing: seen
                      ? null
                      : const Icon(
                          Icons.brightness_1,
                          color: Colors.red,
                          size: 12,
                        ),
                  onTap: () => _markAsSeen(doc.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
