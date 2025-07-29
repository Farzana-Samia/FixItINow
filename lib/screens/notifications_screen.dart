import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final Color backgroundColor = const Color(0xFFF8F4F0);
  final Color accentColor = const Color(0xFFA67C52);
  final Color textColor = const Color(0xFF6B5E5E);

  Future<String?> getCurrentCrUid() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final crDoc = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (crDoc.docs.isEmpty) return null;
    return crDoc.docs.first.id;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchCrNotifications() async* {
    final crId = await getCurrentCrUid();
    if (crId == null) {
      yield [];
      return;
    }

    final snapshots = FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: crId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    await for (var snap in snapshots) {
      yield snap.docs;
    }
  }

  Future<void> markAsSeen(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'seen': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: accentColor),
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: fetchCrNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: GoogleFonts.poppins(color: textColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final message = data['message'] ?? 'No message';
              final seen = data['seen'] == true;
              final time = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedTime = time != null
                  ? DateFormat.yMMMMd().add_jm().format(time)
                  : 'No Timestamp';

              if (!seen) {
                // Mark unseen notification as seen
                markAsSeen(doc.id);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: seen ? Colors.white : const Color(0xFFFFF3E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(
                    seen
                        ? Icons.notifications_none_outlined
                        : Icons.notifications_active_outlined,
                    color: seen ? Colors.grey : Colors.green,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!seen)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 10,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'Time: $formattedTime',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 13,
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
