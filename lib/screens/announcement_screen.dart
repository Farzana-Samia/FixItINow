import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementScreen extends StatelessWidget {
  final String userType; // "admin", "cr", or "team"
  final String? teamType; // null for CR/admin, otherwise team name

  const AnnouncementScreen({super.key, required this.userType, this.teamType});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> announcementStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        title: const Text("Important Announcements"),
        backgroundColor: const Color(0xFF8B5E3C),
        centerTitle: true,
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

          final docs = snapshot.data!.docs;

          final filtered = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final target =
                data['target']?.toString().trim().toUpperCase() ?? 'ALL';

            if (userType == 'admin') return true;
            if (target == 'ALL') return true;
            if (userType == 'cr' && target == 'CR') return true;
            if (userType == 'team') {
              final team = teamType?.trim().toUpperCase();
              if (target == 'TEAM' || target == team) return true;
            }

            return false;
          }).toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Text("No relevant announcements found."),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp;
              final isExpired = data['expired'] == true;

              final textColor = isExpired
                  ? Colors.grey.withOpacity(0.6)
                  : Colors.black;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    data['message'] ?? 'No message',
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "Target: ${data['target']}",
                        style: TextStyle(color: textColor),
                      ),
                      Text(
                        "Posted: ${timestamp.toDate()}",
                        style: TextStyle(color: textColor),
                      ),
                      if (isExpired)
                        Text(
                          "Expired",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: (userType == 'admin' && !isExpired)
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('announcements')
                                .doc(doc.id)
                                .update({'expired': true});
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
