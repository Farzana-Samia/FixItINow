import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  static const kCream = Color(0xFFF8F4F0);
  static const kChoco = Color(0xFF8B5E3C);

  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  // ---------- STATUS DECOR ----------
  IconData _statusIcon(String s) {
    s = s.toLowerCase();
    if (s.contains('completed')) return Icons.verified_rounded;
    if (s.contains('ongoing') || s.contains('progress'))
      return Icons.autorenew_rounded;
    if (s.contains('assigned')) return Icons.person_add_alt_1_rounded;
    if (s.contains('rework')) return Icons.restart_alt_rounded;
    return Icons.more_horiz_rounded; // pending/others
  }

  Color _statusColor(String s) {
    s = s.toLowerCase();
    if (s.contains('completed')) return const Color(0xFF1DB954);
    if (s.contains('ongoing') || s.contains('progress'))
      return const Color(0xFF7C4DFF);
    if (s.contains('assigned')) return const Color(0xFF1C99D3);
    if (s.contains('rework')) return const Color(0xFFE53935);
    return const Color(0xFFFF8C00); // pending
  }

  String _statusLabel(String s) {
    s = s.toLowerCase();
    if (s.contains('completed')) return 'Completed';
    if (s.contains('ongoing') || s.contains('progress')) return 'Ongoing';
    if (s.contains('assigned')) return 'Assigned';
    if (s.contains('rework')) return 'Rework';
    return 'Pending';
  }

  // ---------- DETAIL SHEET ----------
  void _showDetails(Map<String, dynamic> d) {
    final String cid = (d['complaint_id'] ?? d['complaintId'] ?? '')
        .toString()
        .trim();
    final String displayId = cid.isEmpty ? '—' : cid;
    final String type = (d['problem_type'] ?? d['type'] ?? 'Unknown')
        .toString();
    final String loc = (d['room_location'] ?? d['location'] ?? '—').toString();
    final bool priority = (d['priority'] as bool?) ?? false;
    final String status = (d['status'] ?? '').toString();
    final String assignedTeam = (d['assignedTeam'] ?? '—').toString();
    final DateTime? updatedAt = (d['updated_at'] is Timestamp)
        ? (d['updated_at'] as Timestamp).toDate()
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          minChildSize: 0.45,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // colored header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _statusColor(status).withOpacity(.95),
                          _statusColor(status),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(status), color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Complaint ID: $displayId',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // content
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      children: [
                        if (priority)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.priority_high_rounded,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Priority',
                                  style: GoogleFonts.lato(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _infoRow(Icons.category_rounded, 'Type', type),
                        _infoRow(Icons.location_on_rounded, 'Location', loc),
                        _infoRow(
                          Icons.groups_2_rounded,
                          'Assigned to',
                          assignedTeam,
                        ),
                        _infoRow(
                          Icons.update_rounded,
                          'Last Updated',
                          updatedAt == null
                              ? '—'
                              : DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(updatedAt),
                        ),
                        const SizedBox(height: 14),
                        if (d['description'] != null &&
                            (d['description'] as String).trim().isNotEmpty)
                          _longTextBlock('Description', d['description']),
                      ],
                    ),
                  ),

                  // footer button same hue as header
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _statusColor(status),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check),
                          label: Text(
                            'Close',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kChoco),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5A4030),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(fontSize: 15.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _longTextBlock(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A4030),
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.lato(fontSize: 15.5, height: 1.35)),
        ],
      ),
    );
  }

  // ---------- CARD ----------
  Widget _complaintCard(Map<String, dynamic> d) {
    final String cid = (d['complaint_id'] ?? d['complaintId'] ?? '')
        .toString()
        .trim();
    final String displayId = cid.isEmpty ? '—' : cid;
    final String type = (d['problem_type'] ?? d['type'] ?? 'Unknown')
        .toString();
    final String loc = (d['room_location'] ?? d['location'] ?? '—').toString();
    final String status = (d['status'] ?? '').toString();

    final Color sc = _statusColor(status);
    final String sl = _statusLabel(status);
    final IconData si = _statusIcon(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Complaint ID: $displayId',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
            ),
            // status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sc.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sc.withOpacity(0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(si, color: sc, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    sl,
                    style: GoogleFonts.lato(
                      color: sc,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type: $type',
                style: GoogleFonts.lato(
                  color: Colors.black.withOpacity(.70),
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Location: $loc',
                style: GoogleFonts.lato(
                  color: Colors.black.withOpacity(.70),
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.info_outline_rounded, color: kChoco),
          onPressed: () => _showDetails(d),
          tooltip: 'Details',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        // premium header bar different from page bg
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5E3C), Color(0xFFA07250)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'My Complaints',
          style: GoogleFonts.lato(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: _uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cr_complaints')
                  .where('userId', isEqualTo: _uid)
                  .orderBy('updated_at', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 72,
                            color: kChoco.withOpacity(.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No complaints yet',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w800,
                              color: kChoco,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'When you submit complaints, they will appear here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              color: const Color(0xFF6B5E5E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snap.data!.docs;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // count label
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'My Complaints (${docs.length})',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: const Color(0xFF5A4030),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final d = docs[i].data() as Map<String, dynamic>;
                          return _complaintCard(d);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
