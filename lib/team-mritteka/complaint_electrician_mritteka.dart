import 'package:flutter/material.dart';
import 'package:flutter_fix_it_now/screens/notification_mritteka.dart';
import 'package:flutter_fix_it_now/screens/priority_mritteka.dart';
import 'package:flutter_fix_it_now/screens/log_in_team_mritteka.dart';
import 'package:flutter_fix_it_now/screens/project-team-stats.dart';


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
      'id': 'U103',
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
      'tower': 'Tower 2',
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
      'short': 'Switch sparks',
      'description': 'The switch near the bed sparks when used. It’s dangerous.',
      'status': 'Completed',
      'imageUrl': null,
    },

    {
      'id': 'U106',
      'crName': 'Shila',
      'tower': 'Tower 2',
      'room': '108',
      'short': 'Switch sparks',
      'description': 'The switch near the bed sparks when used. It’s dangerous.',
      'status': 'Completed',
      'imageUrl': null,
    },
  ];

  int? selectedIndex;
  String selectedFilter = 'All';
  String sortBy = 'ID';

  final List<String> statuses = ['Pending', 'On Going', 'Completed'];

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'On Going':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

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
            ListTile(leading: const Icon(Icons.report), title: const Text('Complaint'), onTap: () { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComplaintElectricianMritteka()),
            );}),
            ListTile(leading: const Icon(Icons.warning), title: const Text('Announcements'), onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PriorityComplaintPage()),
              );
            }),
            ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifications'), onTap: () { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );}),
            ListTile(leading: const Icon(Icons.history), title: const Text('Complaint stats'), onTap: () { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectorTeamStatsPage()),
            );}),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogInTeamMritteka()),
            );}),
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
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = selectedIndex == index ? null : index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.deepPurple.shade50,
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.deepPurple.shade200,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 18),
                                  const SizedBox(width: 5),
                                  Text("User ID: ${complaint['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    value: complaint['status'],
                                    onChanged: (newStatus) {
                                      setState(() {
                                        complaint['status'] = newStatus!;
                                      });
                                    },
                                    items: statuses.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) =>
                                              FadeTransition(opacity: animation, child: child),
                                          child: Text(
                                            status,
                                            key: ValueKey(status),
                                            style: TextStyle(
                                              color: statusColor(status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("Short: ${complaint['short']}"),
                              if (isSelected) ...[
                                const Divider(height: 20),
                                Text("CR Name: ${complaint['crName']}"),
                                Text("Tower: ${complaint['tower']}"),
                                Text("Room: ${complaint['room']}"),
                                const SizedBox(height: 10),
                                Text("Details: ${complaint['description']}"),
                                if (complaint['imageUrl'] != null) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      complaint['imageUrl'],
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ]
                              ],
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

  ]
      ),
    );
  }
}
