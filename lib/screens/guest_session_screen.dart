import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestSessionScreen extends StatelessWidget {
  const GuestSessionScreen({super.key});

  // ---------- Styles ----------
  static const _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const _valueStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const _monoStyle = TextStyle(
    fontSize: 15,
    fontFeatures: [FontFeature.tabularFigures()],
  );

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
      final Timestamp created =
          (data['timestamp'] ?? data['submitted_at'] ?? loginAt) as Timestamp;

      // Filed within session window?
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
      backgroundColor: const Color(0xFFF1C98D),
      appBar: AppBar(
        backgroundColor: Colors.pink[700],
        title: const Text("CR Rep Sessions"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guest_sessions')
            .orderBy('login_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!.docs;
          if (sessions.isEmpty) {
            return const Center(
              child: Text("No guest sessions found.", style: _labelStyle),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sessionData =
                  sessions[index].data() as Map<String, dynamic>;

              final phone = (sessionData['phone'] ?? 'Unknown').toString();
              final loginAt = sessionData['login_at'] as Timestamp?;
              final expiresAt = sessionData['expires_at'] as Timestamp?;
              final uid = (sessionData['uid'] ?? '').toString();
              final sessionGuestName = (sessionData['name'] ?? '')
                  .toString()
                  .trim();

              return FutureBuilder<Map<String, dynamic>>(
                future: (loginAt != null && expiresAt != null)
                    ? fetchComplaintStatus(uid, loginAt, expiresAt)
                    : Future.value({
                        'exists': false,
                        'id': 'N/A',
                        'guestName': 'Unknown',
                      }),
                builder: (context, complaintSnap) {
                  final cdata = complaintSnap.data ?? {};
                  final complaintExists = (cdata['exists'] ?? false) as bool;
                  final complaintId = (cdata['id'] ?? 'N/A').toString();

                  // Prefer session name; fall back to complaint name; else Unknown
                  final guestName = sessionGuestName.isNotEmpty
                      ? sessionGuestName
                      : (cdata['guestName'] ?? 'Unknown').toString();

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name header
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Name: $guestName",
                                  style: _titleStyle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Two-column info rows (phone + uid)
                          _infoRow(
                            icon: Icons.phone_iphone,
                            label: "Phone",
                            value: phone,
                          ),
                          const SizedBox(height: 6),
                          _infoRow(
                            icon: Icons.vpn_key_outlined,
                            label: "UID",
                            value: uid,
                            valueStyle: _monoStyle,
                          ),

                          const SizedBox(height: 10),
                          const Divider(height: 1),

                          const SizedBox(height: 10),
                          // Times
                          if (loginAt != null)
                            _infoRow(
                              icon: Icons.login,
                              label: "Login At",
                              value: formatDate(loginAt),
                            ),
                          if (expiresAt != null) ...[
                            const SizedBox(height: 6),
                            _infoRow(
                              icon: Icons.hourglass_bottom,
                              label: "Expires At",
                              value: formatDate(expiresAt),
                            ),
                          ],
                          if (expiresAt != null) ...[
                            const SizedBox(height: 6),
                            _infoRow(
                              icon: Icons.logout,
                              label: "Logout Status",
                              value: getLogoutStatus(expiresAt),
                              valueStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                          const Divider(height: 1),

                          const SizedBox(height: 10),
                          // Complaint summary
                          _infoRow(
                            icon: Icons.edit_note_rounded,
                            label: "Complaint",
                            value: complaintExists ? "Yes" : "No",
                          ),
                          const SizedBox(height: 6),
                          _infoRow(
                            icon: Icons.badge_outlined,
                            label: "Complaint ID",
                            value: complaintId,
                            valueStyle: _monoStyle,
                          ),
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

  // A compact, evenly spaced info row
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text("$label: ", style: _labelStyle),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: valueStyle ?? _valueStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
