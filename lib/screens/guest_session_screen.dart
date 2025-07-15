import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestSessionScreen extends StatelessWidget {
  const GuestSessionScreen({super.key});

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy hh:mm a').format(date);
  }

  String getLogoutStatus(Timestamp expiresAt) {
    final now = DateTime.now();
    final expiry = expiresAt.toDate();
    return now.isAfter(expiry) ? "Force Logged Out" : "Self Logged Out";
  }

  Future<Map<String, dynamic>> fetchComplaintStatus(
    String guestUid,
    Timestamp loginAt,
    Timestamp expiresAt,
  ) async {
    final query = await FirebaseFirestore.instance
        .collection('guest_complaints')
        .where('guest_uid', isEqualTo: guestUid)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final Timestamp created = data['timestamp'] ?? loginAt;

      // Check if complaint was filed during session
      if (created.compareTo(loginAt) >= 0 &&
          created.compareTo(expiresAt) <= 0) {
        return {
          'exists': true,
          'id': data['complaint_id'] ?? doc.id,
          'guestName': data['guest_name'] ?? 'Unknown',
        };
      }
    }

    return {'exists': false, 'id': 'N/A', 'guestName': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Sessions"),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guest_sessions')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!.docs;

          if (sessions.isEmpty) {
            return const Center(child: Text("No guest sessions found."));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionData =
                  sessions[index].data() as Map<String, dynamic>;

              final phone = sessionData['phone'] ?? 'Unknown';
              final loginAt = sessionData['login_at'];
              final expiresAt = sessionData['expires_at'];
              final uid = sessionData['uid'] ?? '';
              final sessionGuestName = sessionData['name'];

              return FutureBuilder<Map<String, dynamic>>(
                future: fetchComplaintStatus(uid, loginAt, expiresAt),
                builder: (context, snapshot) {
                  final complaintExists = snapshot.data?['exists'] ?? false;
                  final complaintId = snapshot.data?['id'] ?? 'N/A';

                  // ✅ Fallback to complaint name if session name is null
                  final guestName =
                      sessionGuestName ??
                      snapshot.data?['guestName'] ??
                      'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🙍 Name: $guestName"),
                          Text("📱 Phone: $phone"),
                          Text("🔐 UID: $uid"),
                          if (loginAt != null)
                            Text("🕒 Login At: ${formatDate(loginAt)}"),
                          if (expiresAt != null)
                            Text("⏳ Expires At: ${formatDate(expiresAt)}"),
                          Text(
                            "🚪 Logout Status: ${getLogoutStatus(expiresAt)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "📝 Complaint: ${complaintExists ? 'Yes' : 'No'}",
                          ),
                          Text("🆔 Complaint ID: $complaintId"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
