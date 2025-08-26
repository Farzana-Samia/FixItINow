import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamAnnouncementScreen extends StatelessWidget {
  final String teamName;

  const TeamAnnouncementScreen({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    // Include ALL, TEAM, and the specific team name (assuming targets are stored uppercase)
    final targets = ['ALL', 'TEAM', teamName.toUpperCase()];

    // ✅ Do NOT filter expired; get everything for these targets
    final query = FirebaseFirestore.instance
        .collection('announcements')
        .where('target', whereIn: targets)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('📢 $teamName Announcements'),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Error loading announcements.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No announcements available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final isExpired = data['expired'] == true;
              final message = (data['message'] ?? 'No message').toString();
              final target = (data['target'] ?? 'Unknown').toString();
              final ts = (data['timestamp'] as Timestamp?)?.toDate();

              final formattedTime = ts == null
                  ? 'Unknown Time'
                  : '${ts.day.toString().padLeft(2, '0')}-'
                        '${ts.month.toString().padLeft(2, '0')}-'
                        '${ts.year} '
                        '${ts.hour.toString().padLeft(2, '0')}:'
                        '${ts.minute.toString().padLeft(2, '0')}';

              return Opacity(
                opacity: isExpired ? 0.5 : 1.0, // 👈 fade expired rows
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isExpired
                      ? Colors
                            .green
                            .shade50 // 👈 subtle green tint for expired
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.announcement, color: Colors.pink),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Target: $target'),
                        Text('Posted on: $formattedTime'),
                        if (isExpired) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Expired',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
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
