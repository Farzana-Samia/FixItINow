import 'package:flutter/material.dart';

import 'package:flutter_fix_it_now/screens/complaint_electrician_mritteka.dart';
import 'package:flutter_fix_it_now/screens/notification_mritteka.dart';
import 'package:flutter_fix_it_now/screens/announcement-team-page.dart';
import 'package:flutter_fix_it_now/screens/log_in_team_mritteka.dart';
import 'package:flutter_fix_it_now/screens/project-team-stats.dart';
import 'package:flutter_fix_it_now/screens/complaint_page1.dart';
import 'package:flutter_fix_it_now/profile_team.dart'; // Make sure this file contains ProfileTeam widget

class ComplaintElectricianMritteka extends StatefulWidget {
  const ComplaintElectricianMritteka({super.key});

  @override
  State<ComplaintElectricianMritteka> createState() => _ComplaintElectricianMrittekaState();
}

class _ComplaintElectricianMrittekaState extends State<ComplaintElectricianMritteka> {
  final List<Map<String, dynamic>> complaints = [
    {
      'id': 'U101',
      'crName': 'Mritteka',
      'tower': 'Tower 3',
      'room': '305',
      'short': 'Fan not working',
      'description': 'The ceiling fan is completely non-functional in Room 305. It needs urgent fixing.',
      'status': 'Pending',
      'imageUrl': null,
    },
    {
      'id': 'U102',
      'crName': 'Shila',
      'tower': 'Tower 2',
      'room': '108',
      'short': 'Switch sparks',
      'description': 'The switch near the bed sparks when used. It’s dangerous.',
      'status': 'Completed',
      'imageUrl': null,
    },
    {
      'id': 'U104',
      'crName': 'Shila',
      'tower': 'Tower 4',
      'room': '108',
      'short': 'Switch sparks',
      'description': 'The switch near the bed sparks when used. It’s dangerous.',
      'status': 'Completed',
      'imageUrl': null,
    },
    {
      'id': 'U105',
      'crName': 'Shila',
      'tower': 'Tower 2',
      'room': '108',
      'short': 'fan is not working',
      'description': '.',
      'status': 'Completed',
      'imageUrl': null,
    },
  ];

  String selectedFilter = 'All';
  String sortBy = 'ID';

  final List<String> statuses = ['Pending', 'On Going', 'Completed'];

  List<Map<String, dynamic>> get filteredComplaints {
    List<Map<String, dynamic>> filtered = [...complaints];

    if (selectedFilter != 'All') {
      filtered = filtered.where((c) => c['status'] == selectedFilter).toList();
    }

    if (sortBy == 'ID') {
      filtered.sort((a, b) => a['id'].compareTo(b['id']));
    } else if (sortBy == 'Tower') {
      filtered.sort((a, b) => a['tower'].compareTo(b['tower']));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrician Complaints'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Fix It Now', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Complaint'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintElectricianMritteka()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Complaint stats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectorTeamStatsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  LogInTeamMritteka()),
                );
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedFilter,
                        items: ['All', ...statuses]
                            .map((status) => DropdownMenuItem(value: status, child: Text('Filter: $status')))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<String>(
                        value: sortBy,
                        items: ['ID', 'Tower']
                            .map((field) => DropdownMenuItem(value: field, child: Text('Sort by $field')))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            sortBy = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintDetailsPage(complaintData: complaint),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            border: Border.all(
                              color: Colors.deepPurple.shade200,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(2, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Complaint Info (left side)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Complaint ID: ${complaint['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Short: ${complaint['short']}"),
                                  ],
                                ),
                              ),

                              // Status Dropdown (right side)
                              DropdownButton<String>(
                                value: complaint['status'],
                                items: statuses
                                    .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                                    .toList(),
                                onChanged: (String? newStatus) {
                                  if (newStatus != null) {
                                    setState(() {
                                      // Update the status in the original complaints list by finding the index
                                      final originalIndex = complaints.indexWhere((c) => c['id'] == complaint['id']);
                                      if (originalIndex != -1) {
                                        complaints[originalIndex]['status'] = newStatus;
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
