import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
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

    setState(() {
      crComplaints = crComplaintSnapshot.docs;
      guestComplaints = guestComplaintSnapshot.docs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Complaints (${crComplaints.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...crComplaints.map(
                    (doc) =>
                        ComplaintCard(data: doc.data() as Map<String, dynamic>),
                  ),
                  if (guestComplaints.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Guest Complaints (Linked) (${guestComplaints.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...guestComplaints.map(
                      (doc) => GuestComplaintCard(
                        data: doc.data() as Map<String, dynamic>,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ComplaintCard({super.key, required this.data});

  Widget _buildStatusBadge(String status) {
    String icon = 'submitted.png';
    Color color = Colors.yellow;

    if (status == 'Assigned') {
      icon = 'assigned.png';
      color = Colors.blue;
    } else if (status == 'Ongoing') {
      icon = 'ongoing.png';
      color = Colors.orange;
    } else if (status == 'Completed') {
      icon = 'completed.png';
      color = Colors.green;
    } else if (status == 'Pending') {
      icon = 'pending.png';
      color = Colors.yellow;
    }

    return Row(
      children: [
        Image.asset('assets/images/$icon', height: 18, width: 18),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF8F4F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Complaint ID: ${data['complaint_id'] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 6),
            Text(data['description'] ?? ''),
            const SizedBox(height: 6),
            Text("📍 Location: ${data['location'] ?? ''}"),
            Text("🛠️ Type: ${data['problem_type'] ?? ''}"),
            if (data['priority'] == true)
              const Text("⚠️ Priority", style: TextStyle(color: Colors.red)),
            Text(
              "✅ Assigned to: ${data['assignedTeam'] ?? 'Not assigned'}",
              style: const TextStyle(color: Colors.blue),
            ),
            Text("🕒 Submitted: ${data['timestamp'] ?? ''}"),
          ],
        ),
      ),
    );
  }
}

class GuestComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const GuestComplaintCard({super.key, required this.data});

  Widget _buildStatusBadge(String status) {
    String icon = 'submitted.png';
    Color color = Colors.yellow;

    if (status == 'Assigned') {
      icon = 'assigned.png';
      color = Colors.blue;
    } else if (status == 'Ongoing') {
      icon = 'ongoing.png';
      color = Colors.orange;
    } else if (status == 'Completed') {
      icon = 'completed.png';
      color = Colors.green;
    } else if (status == 'Pending') {
      icon = 'pending.png';
      color = Colors.yellow;
    }

    return Row(
      children: [
        Image.asset('assets/images/$icon', height: 18, width: 18),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF8F4F0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Complaint ID: ${data['complaint_id'] ?? 'N/A'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 6),
            Text(data['description'] ?? ''),
            const SizedBox(height: 6),
            Text("📍 Location: ${data['location'] ?? ''}"),
            Text("🛠️ Type: ${data['problem_type'] ?? ''}"),
            Text("🕒 Submitted: ${data['timestamp'] ?? ''}"),
          ],
        ),
      ),
    );
  }
}
