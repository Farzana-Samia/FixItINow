import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignComplaintScreen extends StatefulWidget {
  const AssignComplaintScreen({super.key});

  @override
  State<AssignComplaintScreen> createState() => _AssignComplaintScreenState();
}

class _AssignComplaintScreenState extends State<AssignComplaintScreen> {
  final List<String> _teams = [
    'Electric',
    'Computer',
    'Projector',
    'Furniture',
    'Water',
  ];

  Future<void> _assignTeam(String collection, String docId, String team) async {
    try {
      String complaintId = '';

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docRef = FirebaseFirestore.instance
            .collection(collection)
            .doc(docId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception("Complaint not found.");
        }

        final data = snapshot.data() as Map<String, dynamic>;

        // ✅ Retrieve the auto-generated complaint_id field (e.g., C0005)
        complaintId = data['complaint_id'] ?? docId;

        transaction.update(docRef, {
          'assignedTeam': team,
          'status': 'Assigned',
        });
      });

      debugPrint('✅ Complaint $docId in $collection assigned to $team');

      // ✅ Send assignment notification with actual complaint_id (e.g., C0005)
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': 'Complaint No $complaintId has been assigned to your team',
        'recipientId': team, // must match teamType in user collection
        'timestamp': Timestamp.now(),
        'seen': false,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Assigned to $team successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {}); // Refresh the list
    } catch (e) {
      debugPrint('❌ Assignment failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to assign complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPendingComplaints() async {
    final List<Map<String, dynamic>> allComplaints = [];

    try {
      final crSnap = await FirebaseFirestore.instance
          .collection('cr_complaints')
          .where('status', isEqualTo: 'Pending')
          .where('assignedTeam', isEqualTo: '')
          .get();

      for (var doc in crSnap.docs) {
        allComplaints.add({
          'id': doc.id,
          'data': doc.data(),
          'collection': 'cr_complaints',
          'userType': 'cr',
        });
      }

      final guestSnap = await FirebaseFirestore.instance
          .collection('guest_complaints')
          .where('status', isEqualTo: 'Pending')
          .where('assignedTeam', isEqualTo: '')
          .get();

      for (var doc in guestSnap.docs) {
        allComplaints.add({
          'id': doc.id,
          'data': doc.data(),
          'collection': 'guest_complaints',
          'userType': 'guest',
        });
      }
    } catch (e) {
      debugPrint('🔥 Firestore error: $e');
    }

    return allComplaints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Complaints"),
        backgroundColor: Colors.pink[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPendingComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("✅ No complaints to assign"));
          }

          final complaints = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final data = complaint['data'];
              final collection = complaint['collection'];
              final docId = complaint['id'];
              final isGuest = complaint['userType'] == 'guest';

              return Card(
                color: isGuest ? Colors.green[50] : null,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🆔 Complaint ID: ${data['complaint_id'] ?? 'Unknown'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "📍 Location: ${data['room_location'] ?? data['location'] ?? 'N/A'}",
                      ),
                      Text("🔧 Type: ${data['problem_type'] ?? 'N/A'}"),
                      Text("📝 Description: ${data['description'] ?? 'N/A'}"),
                      if (data['priority'] == true)
                        const Text(
                          "🔥 Priority",
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      isGuest
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "👤 CR Rep Complaint",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("Name: ${data['guest_name'] ?? ''}"),
                                Text("Roll: ${data['guest_roll'] ?? ''}"),
                                Text("Phone: ${data['guest_phone'] ?? ''}"),
                                const Divider(),
                                Text(
                                  "📌 Linked CR Roll: ${data['linked_cr_roll'] ?? ''}",
                                ),
                                Text(
                                  "CR Dept: ${data['linked_cr_department'] ?? ''} | Sec: ${data['linked_cr_section'] ?? ''}",
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "👤 CR Complaint",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("Roll: ${data['mist_roll'] ?? ''}"),
                                Text(
                                  "Dept: ${data['department'] ?? ''} | Sec: ${data['section'] ?? ''} | Level: ${data['level'] ?? ''}",
                                ),
                              ],
                            ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Assign to Team",
                        ),
                        items: _teams.map((team) {
                          return DropdownMenuItem(
                            value: team,
                            child: Text(team),
                          );
                        }).toList(),
                        onChanged: (team) async {
                          if (team != null) {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirm Assignment"),
                                content: Text(
                                  "Assign this complaint to $team?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Assign"),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await _assignTeam(collection, docId, team);
                            }
                          }
                        },
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
