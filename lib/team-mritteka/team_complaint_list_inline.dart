import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_complaint_details_screen.dart';

class TeamComplaintListInline extends StatelessWidget {
  final String teamName;

  const TeamComplaintListInline({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    final complaintsRef = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text("$teamName Complaints"),
        backgroundColor: Colors.pink[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: complaintsRef
            .collection('cr_complaints')
            .where('assignedTeam', isEqualTo: teamName)
            .snapshots(),
        builder: (context, crSnapshot) {
          if (crSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final crDocs = crSnapshot.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: complaintsRef
                .collection('guest_complaints')
                .where('assignedTeam', isEqualTo: teamName)
                .snapshots(),
            builder: (context, guestSnapshot) {
              if (guestSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final guestDocs = guestSnapshot.data?.docs ?? [];

              // ✅ Add these debug prints here
              print("🔍 teamName passed: $teamName");
              print(
                "📦 CR Docs: ${crDocs.length}, Guest Docs: ${guestDocs.length}",
              );

              for (var doc in crDocs) {
                final data = doc.data() as Map<String, dynamic>;
                print(
                  "🧾 CR AssignedTeam: ${data['assignedTeam']}, Status: ${data['status']}",
                );
              }

              for (var doc in guestDocs) {
                final data = doc.data() as Map<String, dynamic>;
                print(
                  "👤 Guest AssignedTeam: ${data['assignedTeam']}, Status: ${data['status']}",
                );
              }

              final allDocs = [
                ...crDocs.map(
                      (e) => {
                    'data': e.data() as Map<String, dynamic>,
                    'docId': e.id,
                    'type': 'cr_complaints',
                  },
                ),
                ...guestDocs.map(
                      (e) => {
                    'data': e.data() as Map<String, dynamic>,
                    'docId': e.id,
                    'type': 'guest_complaints',
                  },
                ),
              ];

              if (allDocs.isEmpty) {
                return const Center(
                  child: Text("No complaints assigned to your team."),
                );
              }

              // ... rest of your ListView.builder

              return ListView.builder(
                itemCount: allDocs.length,
                itemBuilder: (context, index) {
                  final complaint =
                  allDocs[index]['data'] as Map<String, dynamic>;
                  final docId = allDocs[index]['docId'] as String;
                  final collection = allDocs[index]['type'] as String;
                  final isPriority = complaint['priority'] == true;

                  return Card(
                    color: isPriority
                        ? const Color.fromARGB(169, 255, 236, 68)
                        : null,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: ListTile(
                      title: Text(
                        "Complaint ID: ${complaint['complaint_id'] ?? 'Unknown'}",
                      ),
                      subtitle: Text(
                        complaint['description'] ?? 'No description',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamComplaintDetailsScreen(
                              data: complaint,
                              docId: docId,
                              collection: collection,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}