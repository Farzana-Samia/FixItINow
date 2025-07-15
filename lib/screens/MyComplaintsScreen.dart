import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  String? mistRoll;
  List<Map<String, dynamic>> crComplaints = [];
  List<Map<String, dynamic>> guestLinkedComplaints = [];

  @override
  void initState() {
    super.initState();
    fetchAllComplaints();
  }

  Future<void> fetchAllComplaints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      mistRoll = userDoc.data()?['mist_roll'];

      if (mistRoll == null) return;

      // Fetch CR's own complaints
      final crSnapshot = await FirebaseFirestore.instance
          .collection('cr_complaints')
          .where('mist_roll', isEqualTo: mistRoll)
          .orderBy('submitted_at', descending: true)
          .get();

      // Fetch guest complaints linked to this CR
      final guestSnapshot = await FirebaseFirestore.instance
          .collection('guest_complaints')
          .where('linked_cr_roll', isEqualTo: mistRoll)
          .orderBy('submitted_at', descending: true)
          .get();
      print("Mist Roll: $mistRoll");
      print("CR Complaints Found: ${crSnapshot.docs.length}");
      print("Guest Complaints Found: ${guestSnapshot.docs.length}");

      for (var doc in crSnapshot.docs) {
        print("CR complaint: ${doc.data()}");
      }
      for (var doc in guestSnapshot.docs) {
        print("Guest complaint: ${doc.data()}");
      }

      setState(() {
        crComplaints = crSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        guestLinkedComplaints = guestSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints"),
        backgroundColor: Colors.pink[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: crComplaints.isEmpty && guestLinkedComplaints.isEmpty
          ? const Center(child: Text("No complaints found."))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (crComplaints.isNotEmpty)
                  _buildSection("My Complaints", crComplaints),
                if (guestLinkedComplaints.isNotEmpty)
                  _buildSection(
                    "Guest Complaints (Linked)",
                    guestLinkedComplaints,
                    isGuest: true,
                  ),
              ],
            ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, dynamic>> complaints, {
    bool isGuest = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title (${complaints.length})",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...complaints.map((data) {
          final complaintId = data['complaint_id'] ?? 'Unknown';
          final description = data['description'] ?? '';
          final location = data['room_location'] ?? 'No location';
          final type = data['problem_type'] ?? 'No type';
          final status = data['status'] ?? 'Pending';
          final priority = data['priority'] == true;
          final assignedTeam = (data['assignedTeam'] ?? '').toString();
          final submittedAt = (data['submitted_at'] as Timestamp?)?.toDate();
          final completedAt = (data['completed_at'] as Timestamp?)?.toDate();

          Color cardColor = Colors.white;
          if (status == 'Completed') {
            cardColor = Colors.green[100]!;
          } else if (assignedTeam.isNotEmpty) {
            cardColor = Colors.blue[100]!;
          }

          return Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                "Complaint ID: $complaintId",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Problem Details"),
                  Text(description),
                  const SizedBox(height: 4),
                  Text("Type: $type"),
                  Text("Location: $location"),
                  Text("Status: $status"),
                  if (priority)
                    const Text(
                      "⚠️ Priority Complaint",
                      style: TextStyle(color: Colors.red),
                    ),
                  if (assignedTeam.isNotEmpty)
                    Text(
                      "✅ Assigned to: $assignedTeam",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  if (completedAt != null)
                    Text(
                      "✅ Completed on: ${completedAt.toString().split('.').first}",
                    ),
                  if (submittedAt != null)
                    Text(
                      "🕒 Submitted on: ${submittedAt.toString().split('.').first}",
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
