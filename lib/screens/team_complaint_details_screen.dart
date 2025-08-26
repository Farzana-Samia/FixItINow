import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamComplaintDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final String collection;

  const TeamComplaintDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
    required this.collection,
  });

  Future<void> _updateStatus(
    BuildContext context,
    String newStatus,
    String message,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(collection)
          .doc(docId);
      await docRef.update({'status': newStatus});

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint("❌ Error updating status: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _markAsCompleted(BuildContext context) async {
    try {
      final complaintDoc = FirebaseFirestore.instance
          .collection(collection)
          .doc(docId);

      await complaintDoc.update({
        'status': 'Team_Completed',
        'updated_at': FieldValue.serverTimestamp(),
      });

      final complaintSnapshot = await complaintDoc.get();
      final complaintData = complaintSnapshot.data() as Map<String, dynamic>;

      final crRoll = collection == 'cr_complaints'
          ? complaintData['mist_roll']
          : complaintData['linked_cr_roll'];

      if (crRoll != null) {
        final crQuery = await FirebaseFirestore.instance
            .collection('user')
            .where('mist_roll', isEqualTo: crRoll)
            .limit(1)
            .get();

        if (crQuery.docs.isNotEmpty) {
          final recipientId = crQuery.docs.first.id;

          /// Get the latest rejectionReason if present
          final rejectionReason = complaintData.containsKey('rejection_reason')
              ? complaintData['rejection_reason']
              : null;

          final message = rejectionReason != null
              ? 'Complaint ${complaintData['complaint_id']} is completed again after rework. Please verify again.'
              : 'Complaint ${complaintData['complaint_id']} is completed. Is the solution satisfactory?';

          await FirebaseFirestore.instance.collection('notifications').add({
            'message': message,
            'recipientId': recipientId,
            'timestamp': FieldValue.serverTimestamp(),
            'seen': false,
            'complaintId': complaintData['complaint_id'],
            'requiresVerification': true,
          });
        }
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as Completed! Awaiting CR confirmation.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error marking complete: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while completing.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'Unknown').toString();
    final isOngoing = status == 'Ongoing';
    final isAssigned = status == 'Assigned';
    final isTeamCompleted = status == 'Team_Completed';
    final isFinalCompleted = status == 'Final_Completed';
    final isRework = status == 'Rework';
    final isPriority = data['priority'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Details"),
        backgroundColor: Colors.pink[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildRow("Complaint ID", data['complaint_id'] ?? 'N/A'),
            buildRow("Issue", data['problem_type'] ?? 'N/A'),
            buildRow(
              "Location",
              data['room_location'] ?? data['location'] ?? 'Unknown',
            ),
            buildRow("Description", data['description'] ?? 'No description'),
            buildRow("Status", status),
            buildRow(
              "Priority",
              isPriority ? 'Yes' : 'No',
              isPriority: isPriority,
            ),
            const SizedBox(height: 24),

            if (isAssigned)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Start Work"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => _updateStatus(
                  context,
                  "Ongoing",
                  "Work started on complaint.",
                ),
              ),

            if (isOngoing)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Mark as Completed"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 170, 252, 248),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => _markAsCompleted(context),
              ),

            if (isFinalCompleted)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.verified, size: 60, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      "This complaint is resolved and verified by CR.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            if (isTeamCompleted)
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.hourglass_bottom,
                      size: 60,
                      color: Color.fromARGB(255, 102, 255, 0),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Waiting for CR to verify completion.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            if (isRework)
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Resume Rework"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 231, 51, 60),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () => _updateStatus(
                  context,
                  "Ongoing",
                  "Resumed work on complaint after CR rejection.",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, dynamic value, {bool isPriority = false}) {
    return Card(
      color: isPriority ? const Color.fromARGB(169, 255, 236, 68) : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value?.toString() ?? 'N/A'),
      ),
    );
  }
}
