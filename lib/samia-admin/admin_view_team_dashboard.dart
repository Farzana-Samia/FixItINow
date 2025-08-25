import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminViewTeamDashboard extends StatelessWidget {
  final String teamType;
  const AdminViewTeamDashboard({super.key, required this.teamType});

  Future<List<Map<String, dynamic>>> fetchTeamMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userType', isEqualTo: 'team')
        .where('teamType', isEqualTo: teamType)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? 'Unknown',
        'phone': data['phone'] ?? 'N/A',
        'designation': data['designation'] ?? '',
      };
    }).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchTeamComplaints() async {
    List<Map<String, dynamic>> all = [];

    final collections = ['cr_complaints', 'guest_complaints'];
    for (String col in collections) {
      final query = await FirebaseFirestore.instance
          .collection(col)
          .where('assignedTeam', isEqualTo: teamType)
          .get();

      all.addAll(
        query.docs.map(
          (doc) => {
            ...doc.data(),
            'id': doc.id,
            'complaint_id': doc['complaint_id'] ?? doc.id,
            'description': doc['description'] ?? '',
            'status': doc['status'] ?? '',
          },
        ),
      );
    }

    return {
      'Pending': all.where((c) => c['status'] == 'Assigned').toList(),
      'Ongoing': all
          .where((c) => c['status'] == 'Ongoing' || c['status'] == 'Rework')
          .toList(),
      'Completed': all.where((c) => c['status'] == 'Final_Completed').toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamType Team Overview'),
        backgroundColor: Colors.pink[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTeamMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No team members found.");
                }

                final members = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "👥 Team Members",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...members.map(
                          (m) => ListTile(
                            title: Text(m['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m['phone']),
                                if (m['designation'].toString().isNotEmpty)
                                  Text(m['designation']),
                              ],
                            ),
                            leading: const Icon(Icons.person),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: fetchTeamComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Text("No complaint data available.");
                }

                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🛠️ Complaint Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (data['Pending']!.isNotEmpty)
                      _buildStatusSection(
                        "Pending Complaints",
                        data['Pending']!,
                        Colors.orange[100]!,
                        'assets/images/pending.png',
                      ),
                    if (data['Ongoing']!.isNotEmpty)
                      _buildStatusSection(
                        "Ongoing Complaints",
                        data['Ongoing']!,
                        Colors.yellow[100]!,
                        'assets/images/in_progress.png',
                      ),
                    if (data['Completed']!.isNotEmpty)
                      _buildStatusSection(
                        "Completed Complaints",
                        data['Completed']!,
                        Colors.green[100]!,
                        'assets/images/completed.png',
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    String title,
    List<Map<String, dynamic>> complaints,
    Color color,
    String iconPath,
  ) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(iconPath, width: 24, height: 24),
                const SizedBox(width: 8),
                Text(
                  "$title (${complaints.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...complaints.map(
              (doc) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Complaint ID: ${doc['complaint_id']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Problem Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(doc['description'] ?? 'No description'),
                  const SizedBox(height: 4),
                  Text("Status: ${doc['status']}"),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
