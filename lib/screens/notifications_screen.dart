import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'complaint_verification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No current user found.');
        return;
      }
      print('DEBUG: Current Firebase UID = ${user.uid}');
      currentUserId = user.uid;
      setState(() {}); // Rebuild UI now that UID is ready
    } catch (e) {
      print('ERROR while fetching current user: $e');
    }
  }

  Future<void> _markAsSeen(DocumentReference docRef) async {
    try {
      await docRef.update({'seen': true});
      print('DEBUG: Notification marked as seen');
    } catch (e) {
      print('ERROR updating seen status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('ERROR fetching notifications: ${snapshot.error}');
            return Center(child: Text('Error loading notifications.'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedTime = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(timestamp);
              final message = data['message'] ?? '';
              final requiresVerification = data['requiresVerification'] == true;
              final complaintId = data['complaintId'] ?? '';
              final rejectionReason = data['rejectionReason']; // ✅ NEW FIELD
              final seen = data['seen'] == true;

              return GestureDetector(
                onTap: () async {
                  await _markAsSeen(doc.reference);
                  if (requiresVerification && complaintId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintVerificationScreen(
                          complaintId: complaintId,
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  color: requiresVerification
                      ? Colors.red.shade50
                      : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      requiresVerification && !seen
                          ? Icons.notification_important
                          : Icons.notifications,
                      color: requiresVerification && !seen
                          ? Colors.red
                          : Colors.grey,
                    ),
                    title: Text(message),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formattedTime),
                        if (rejectionReason != null &&
                            rejectionReason.toString().isNotEmpty)
                          Text(
                            'Reason for rework: $rejectionReason',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
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
