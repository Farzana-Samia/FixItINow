import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  // --- DATA (unchanged logic) ---
  List<DocumentSnapshot> crComplaints = [];
  List<DocumentSnapshot> guestComplaints = [];
  bool isLoading = true;
  String? currentMistRoll;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final crSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: user.email)
        .where('userType', isEqualTo: 'cr')
        .get();

    if (crSnapshot.docs.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    currentMistRoll = crSnapshot.docs.first['mist_roll'];

    final crComplaintSnapshot = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .where('mist_roll', isEqualTo: currentMistRoll)
        .get();

    final guestComplaintSnapshot = await FirebaseFirestore.instance
        .collection('guest_complaints')
        .where('linked_cr_roll', isEqualTo: currentMistRoll)
        .get();

    // ---- NEW: sort by numeric part of complaint_id (desc) ----
    int _extractId(DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      final raw = (data['complaint_id'] ?? data['complaintId'] ?? '')
          .toString();
      final m = RegExp(r'\d+').firstMatch(raw);
      return int.tryParse(m?.group(0) ?? '0') ?? 0;
    }

    final sortedCr = [...crComplaintSnapshot.docs]
      ..sort((a, b) => _extractId(b).compareTo(_extractId(a)));
    final sortedGuest = [...guestComplaintSnapshot.docs]
      ..sort((a, b) => _extractId(b).compareTo(_extractId(a)));
    // ----------------------------------------------------------

    setState(() {
      crComplaints = sortedCr;
      guestComplaints = sortedGuest;
      isLoading = false;
    });
  }

  // ---------- STATUS DECOR (fix: team_completed handled first) ----------
  IconData _statusIcon(String s) {
    final x = s.trim().toLowerCase().replaceAll(' ', '_');
    if (x.contains('team_completed'))
      return Icons.check_circle_outline_rounded; // amber
    if (x.contains('final_completed') ||
        x == 'completed' ||
        (x.contains('final') && x.contains('completed'))) {
      return Icons.verified_rounded; // green
    }
    if (x.contains('ongoing') ||
        x.contains('in_progress') ||
        x.contains('working')) {
      return Icons.autorenew_rounded;
    }
    if (x.contains('assigned') || x.contains('team_assigned')) {
      return Icons.person_add_alt_1_rounded;
    }
    if (x.contains('rework')) return Icons.restart_alt_rounded;
    return Icons.more_horiz_rounded; // pending/others
  }

  Color _statusColor(String s) {
    final x = s.trim().toLowerCase().replaceAll(' ', '_');
    if (x.contains('team_completed')) return const Color(0xFFFFC107); // amber
    if (x.contains('final_completed') ||
        x == 'completed' ||
        (x.contains('final') && x.contains('completed'))) {
      return const Color(0xFF1DB954); // green
    }
    if (x.contains('ongoing') ||
        x.contains('in_progress') ||
        x.contains('working'))
      return const Color(0xFF7C4DFF);
    if (x.contains('assigned') || x.contains('team_assigned'))
      return const Color(0xFF1C99D3);
    if (x.contains('rework')) return const Color(0xFFE53935);
    return const Color(0xFFFF8C00); // pending
  }

  String _statusLabel(String s) {
    final x = s.trim().toLowerCase().replaceAll(' ', '_');
    if (x.contains('team_completed')) return 'Team Done';
    if (x.contains('final_completed') ||
        x == 'completed' ||
        (x.contains('final') && x.contains('completed'))) {
      return 'Completed';
    }
    if (x.contains('ongoing') ||
        x.contains('in_progress') ||
        x.contains('working'))
      return 'Ongoing';
    if (x.contains('assigned') || x.contains('team_assigned'))
      return 'Assigned';
    if (x.contains('rework')) return 'Rework';
    return 'Pending';
  }

  DateTime? _pickUpdated(Map<String, dynamic> d) {
    // try common timestamp fields (convert if present)
    for (final k in [
      'updated_at',
      'lastUpdated',
      'submitted_at',
      'timestamp',
    ]) {
      final v = d[k];
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
    }
    return null;
  }

  // --- DETAILS SHEET ---
  void _showDetails(Map<String, dynamic> d) {
    final String complaintId = (d['complaint_id'] ?? d['complaintId'] ?? '')
        .toString()
        .trim();
    final String displayId = complaintId.isEmpty ? '—' : complaintId;

    final String status = (d['status'] ?? '').toString();
    final bool priority = (d['priority'] as bool?) ?? false;

    final String type = (d['problem_type'] ?? d['type'] ?? 'Unknown')
        .toString();
    final String location = (d['room_location'] ?? d['location'] ?? '—')
        .toString();
    final String assignedTeam = (d['assignedTeam'] ?? '—').toString();
    final String description = (d['description'] ?? '').toString();
    final DateTime? updatedAt = _pickUpdated(d);

    final Color sc = _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // Header like screenshot (green when completed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [sc.withOpacity(.95), sc],
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
                            horizontal: 12,
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

                  // Body
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
                        _infoRow(
                          Icons.location_on_rounded,
                          'Location',
                          location,
                        ),
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
                        if (description.trim().isNotEmpty)
                          _longTextBlock('Description', description),
                      ],
                    ),
                  ),

                  // Footer button (same hue)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sc,
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
          Icon(icon, color: const Color(0xFF8B5E3C)),
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

  // --- Card for each item (list) ---
  Widget _complaintCard(Map<String, dynamic> data) {
    final String cid = (data['complaint_id'] ?? data['complaintId'] ?? '')
        .toString()
        .trim();
    final String displayId = cid.isEmpty ? '—' : cid;
    final String type = (data['problem_type'] ?? data['type'] ?? 'Unknown')
        .toString();
    final String loc = (data['room_location'] ?? data['location'] ?? '—')
        .toString();
    final String status = (data['status'] ?? '').toString();

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
          tooltip: 'Details',
          icon: const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF8B5E3C),
          ),
          onPressed: () => _showDetails(data),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My complaints (CR)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                    child: Text(
                      'My Complaints (${crComplaints.length})',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF5A4030),
                      ),
                    ),
                  ),
                  ...crComplaints.map(
                    (doc) => _complaintCard(doc.data() as Map<String, dynamic>),
                  ),

                  // Linked guest complaints (if any)
                  if (guestComplaints.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Text(
                        'Guest Complaints (Linked) (${guestComplaints.length})',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF5A4030),
                        ),
                      ),
                    ),
                    ...guestComplaints.map(
                      (doc) =>
                          _complaintCard(doc.data() as Map<String, dynamic>),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
