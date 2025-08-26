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

  Widget buildComplaintTile(
    Map<String, dynamic> data,
    String status,
    bool isGuest,
  ) {
    final complaintId = data['complaint_id'] ?? 'Unknown';
    final type = data['problem_type'] ?? '';
    final location = data['room_location'] ?? data['location'] ?? '';
    final description = data['description'] ?? '';
    final assignedTeam = data['assignedTeam'] ?? '';
    final priority = data['priority'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Complaint ID: $complaintId",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            getStatusIcon(status),
          ],
        ),
        subtitle: Text(
          "Type: $type\nLocation: $location",
          style: const TextStyle(height: 1.5),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.brown),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Complaint Details"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description: $description"),
                    Text("Type: $type"),
                    Text("Location: $location"),
                    if (priority)
                      const Text(
                        "⚠️ Priority",
                        style: TextStyle(color: Colors.red),
                      ),
                    if (assignedTeam.isNotEmpty)
                      Text("Assigned to: $assignedTeam"),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.more_horiz, color: Colors.orange),
            SizedBox(width: 4),
            Text("Pending", style: TextStyle(color: Colors.orange)),
          ],
        );
      case 'Assigned':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person_add_alt, color: Colors.blue),
            SizedBox(width: 4),
            Text("Assigned", style: TextStyle(color: Colors.blue)),
          ],
        );
      case 'Ongoing':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.construction, color: Colors.deepOrange),
            SizedBox(width: 4),
            Text("Ongoing", style: TextStyle(color: Colors.deepOrange)),
          ],
        );
      case 'Team_Completed':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.amber),
            const SizedBox(width: 4),
            const Text(
              'Team Done',
              style: TextStyle(color: Colors.amber),
            ),
          ],
        );

      case 'Final_Completed':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified, color: Colors.green),
            SizedBox(width: 4),
            Text("Completed", style: TextStyle(color: Colors.green)),
          ],
        );
      case 'Rework':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.replay_circle_filled, color: Colors.redAccent),
            SizedBox(width: 4),
            Text("Rework", style: TextStyle(color: Colors.redAccent)),
          ],
        );
      default:
        return const SizedBox();
    }
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
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                  const SizedBox(height: 6),
                  ...crComplaints.map(
                    (doc) => buildComplaintTile(
                      doc.data() as Map<String, dynamic>,
                      doc['status'] ?? 'Pending',
                      false,
                    ),
                  ),
                  if (guestComplaints.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Guest Complaints (Linked) (${guestComplaints.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...guestComplaints.map(
                      (doc) => buildComplaintTile(
                        doc.data() as Map<String, dynamic>,
                        doc['status'] ?? 'Pending',
                        true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
