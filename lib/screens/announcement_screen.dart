import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnnouncementScreen extends StatelessWidget {
  final String userType; // "admin", "cr", or "team"
  final String? teamType; // null for CR/admin, otherwise team name

  const AnnouncementScreen({super.key, required this.userType, this.teamType});

  // ===== THEME =====
  static const Color kCream = Color(0xFFF8F4F0);
  static const Color kText = Color(0xFF2F2A28);

  Color _colorForTarget(String t) {
    final tt = t.toUpperCase();
    if (tt == 'ALL') return const Color(0xFF06D6A0); // teal
    if (tt == 'CR') return const Color(0xFF7F5AF0); // purple
    if (tt == 'TEAM') return const Color(0xFF1C99D3); // blue
    // specific team names → consistent colorful look
    switch (tt) {
      case 'ELECTRIC':
        return const Color(0xFFFF7B00);
      case 'COMPUTER':
        return const Color(0xFF1C99D3);
      case 'FURNITURE':
        return const Color(0xFF06D6A0);
      case 'WATER':
        return const Color(0xFF00BFA6);
      case 'PROJECTOR':
        return const Color(0xFF7C4DFF);
      default:
        return const Color(0xFF8E24AA); // fallback magenta
    }
  }

  Widget _chip(String label, Color color, {IconData? icon, bool light = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light ? color.withOpacity(.12) : color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: light ? color : Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              color: light ? color : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: kCream,

      // REPLACE ONLY THE appBar: ... IN YOUR Scaffold WITH THIS:
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: const Color(0xFF8B5E3C),
          elevation: 0,
          automaticallyImplyLeading: true,
          toolbarHeight: 120, // tall bar
          centerTitle: true, // centered
          title: const Text(
            'Important Announcements',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No announcements available.',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
            );
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
            return Center(
              child: Text(
                'No relevant announcements found.',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data() as Map<String, dynamic>;

              final String message = (data['message'] ?? 'No message')
                  .toString()
                  .trim();
              final String target = (data['target'] ?? 'ALL').toString().trim();
              final bool isExpired = data['expired'] == true;
              final Timestamp ts = data['timestamp'] as Timestamp;
              final DateTime posted = ts.toDate();

              final Color accent = _colorForTarget(target);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: isExpired ? 0.55 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // colored top border / accent
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // circular icon badge with gradient
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [accent.withOpacity(.85), accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: kText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // chips row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _chip(
                              'Target: $target',
                              accent,
                              icon: Icons.group_work_rounded,
                            ),
                            _chip(
                              DateFormat('dd MMM yyyy, hh:mm a').format(posted),
                              const Color(0xFF5E6B79),
                              icon: Icons.schedule_rounded,
                              light: true,
                            ),
                            if (isExpired)
                              _chip(
                                'Expired',
                                const Color(0xFFE53935),
                                icon: Icons.error_outline_rounded,
                                light: false,
                              ),
                          ],
                        ),
                      ),

                      // admin actions
                      if (userType == 'admin' && !isExpired)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFE53935),
                                ),
                                icon: const Icon(Icons.cancel_rounded),
                                label: const Text(
                                  'Mark Expired',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(
                                        'Expire Announcement',
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to mark this announcement as expired?',
                                        style: GoogleFonts.lato(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE53935,
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Expire'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await FirebaseFirestore.instance
                                        .collection('announcements')
                                        .doc(doc.id)
                                        .update({'expired': true});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
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
