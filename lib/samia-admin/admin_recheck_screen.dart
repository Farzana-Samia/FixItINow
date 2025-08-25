import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRecheckScreen extends StatefulWidget {
  const AdminRecheckScreen({super.key});

  @override
  State<AdminRecheckScreen> createState() => _AdminRecheckScreenState();
}

class _AdminRecheckScreenState extends State<AdminRecheckScreen> {
  List<Map<String, dynamic>> complaintsNeedingRecheck = [];

  @override
  void initState() {
    super.initState();
    fetchReworkComplaints();
  }

  Future<void> fetchReworkComplaints() async {
    List<Map<String, dynamic>> allRework = [];

    // Fetch CR complaints
    final crSnapshot = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .where('status', isEqualTo: 'Rework')
        .get();

    for (var doc in crSnapshot.docs) {
      final data = doc.data();
      data['docId'] = doc.id;
      data['collection'] = 'cr_complaints';
      data['source'] = 'CR';
      data['complaintId'] = data['complaint_id'] ?? doc.id;
      allRework.add(data);
    }

    // Fetch Guest complaints
    final guestSnapshot = await FirebaseFirestore.instance
        .collection('guest_complaints')
        .where('status', isEqualTo: 'Rework')
        .get();

    for (var doc in guestSnapshot.docs) {
      final data = doc.data();
      data['docId'] = doc.id;
      data['collection'] = 'guest_complaints';
      data['source'] = 'Guest';
      data['complaintId'] = data['complaint_id'] ?? doc.id;
      allRework.add(data);
    }

    setState(() {
      complaintsNeedingRecheck = allRework;
    });
  }

  Future<void> _reassignComplaint(
    BuildContext context,
    Map<String, dynamic> complaint,
  ) async {
    String? selectedTeam;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reassign Complaint"),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Team'),
          items: const [
            DropdownMenuItem(value: 'Electric', child: Text('Electric')),
            DropdownMenuItem(value: 'Water', child: Text('Water')),
            DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
            DropdownMenuItem(value: 'Computer', child: Text('Computer')),
            DropdownMenuItem(value: 'Projector', child: Text('Projector')),
          ],
          onChanged: (value) => selectedTeam = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedTeam != null) {
                Navigator.pop(context);

                final docRef = FirebaseFirestore.instance
                    .collection(complaint['collection'])
                    .doc(complaint['docId']);

                // ✅ Step 1: Save rework log
                await docRef.collection('rework_logs').add({
                  'previousTeam': complaint['assignedTeam'] ?? 'Unknown',
                  'reassignedTo': selectedTeam,
                  'rejection_reason': complaint['rejection_reason'],
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // ✅ Step 2: Update complaint (retain for admin tracking)
                await docRef.update({
                  'assignedTeam': selectedTeam,
                  'status': 'Assigned',
                  'updated_at': FieldValue.serverTimestamp(),
                  'rework_phase': true,
                  'rejection_reason': FieldValue.delete(),
                });

                // ✅ Step 3: Notify reassigned team
                final teamUserQuery = await FirebaseFirestore.instance
                    .collection('user')
                    .where('userType', isEqualTo: 'team')
                    .where('teamType', isEqualTo: selectedTeam)
                    .limit(1)
                    .get();

                if (teamUserQuery.docs.isNotEmpty) {
                  final teamUserId = teamUserQuery.docs.first.id;

                  await FirebaseFirestore.instance.collection('notifications').add({
                    'message':
                        'Complaint ${complaint['complaintId']} has been reassigned to your team for rework.\nReason: ${complaint['rejection_reason'] ?? 'No reason provided'}',
                    'recipientId': teamUserId,
                    'timestamp': FieldValue.serverTimestamp(),
                    'seen': false,
                  });
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Complaint reassigned successfully."),
                    ),
                  );
                  fetchReworkComplaints(); // Refresh list
                }
              }
            },
            child: const Text("Reassign"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints Needing Recheck"),
        backgroundColor: Colors.pink[700],
      ),
      body: complaintsNeedingRecheck.isEmpty
          ? const Center(child: Text("No complaints marked for rework."))
          : ListView.builder(
              itemCount: complaintsNeedingRecheck.length,
              itemBuilder: (context, index) {
                final complaint = complaintsNeedingRecheck[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text("Complaint ID: ${complaint['complaintId']}"),
                    subtitle: Text(
                      "Reason: ${complaint['rejection_reason'] ?? 'N/A'}",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _reassignComplaint(context, complaint),
                      child: const Text("Reassign"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
