import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerifyResolutionScreen extends StatefulWidget {
  final String complaintId;
  final bool isGuest; // to check cr_complaints or guest_complaints

  const VerifyResolutionScreen({
    required this.complaintId,
    required this.isGuest,
  });

  @override
  _VerifyResolutionScreenState createState() => _VerifyResolutionScreenState();
}

class _VerifyResolutionScreenState extends State<VerifyResolutionScreen> {
  late DocumentReference complaintRef;
  late String complaintType;
  String status = '';
  String details = '';
  String? rejectionReason;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    complaintType = widget.isGuest ? 'guest_complaints' : 'cr_complaints';
    complaintRef = FirebaseFirestore.instance
        .collection(complaintType)
        .doc(widget.complaintId);
    fetchComplaint();
  }

  Future<void> fetchComplaint() async {
    final snapshot = await complaintRef.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        status = data['status'] ?? '';
        details = data['description'] ?? '';
        rejectionReason = data['rejection_reason'];
        isLoading = false;
      });
    }
  }

  Future<void> updateStatus(String newStatus, {String? reason}) async {
    await complaintRef.update({
      'status': newStatus,
      'updated_at': Timestamp.now(),
      if (reason != null) 'rejection_reason': reason,
      if (reason == null) 'rejection_reason': FieldValue.delete(),
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'message': newStatus == "Final_Completed"
          ? "Complaint ${widget.complaintId} marked as Final Completed."
          : "Complaint ${widget.complaintId} requires rework.",
      'recipientId': 'admin', // or team based on logic
      'timestamp': Timestamp.now(),
      'seen': false,
    });

    await fetchComplaint(); // refresh view
  }

  void showRejectionDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reason for Rejection'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Explain why the complaint is not resolved',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context);
                updateStatus("Rework", reason: reason);
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text('Verify Resolution')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Complaint ID: ${widget.complaintId}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Details: $details"),
            SizedBox(height: 20),
            if (status == "Team_Completed" || status == "Rework") ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => updateStatus("Final_Completed"),
                      icon: Icon(Icons.check_circle, color: Colors.white),
                      label: Text("Satisfied"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: showRejectionDialog,
                      icon: Icon(Icons.cancel, color: Colors.white),
                      label: Text("Not Satisfied"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == "Final_Completed") ...[
              SizedBox(height: 20),
              Text(
                "You confirmed this complaint as resolved.",
                style: TextStyle(color: Colors.green),
              ),
            ] else if (status == "Rework") ...[
              SizedBox(height: 20),
              Text(
                "You rejected this complaint.",
                style: TextStyle(color: Colors.red),
              ),
              if (rejectionReason != null)
                Text(
                  "Reason: $rejectionReason",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
