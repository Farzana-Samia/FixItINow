import 'package:flutter/material.dart';

class AssignComplaintsPage extends StatefulWidget {
  const AssignComplaintsPage({super.key});

  @override
  State<AssignComplaintsPage> createState() => _AssignComplaintsPageState();
}

class _AssignComplaintsPageState extends State<AssignComplaintsPage> {
  // Dummy data for complaints.
  // 'guest_name', 'guest_roll', 'guest_phone', 'linked_cr_roll', 'cr_dept_sec'
  // are included. Their presence (not null) will make the corresponding UI section appear.
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'C0001',
      'location': ' Tower 3, Room 402',
      'type': 'Electric',
      'description': 'AC remote is not working',
      'reported_by': 'Arif Abdullah',
      'guest_name': 'Farzana Mozammel Samia', // Guest data present for this complaint
      'guest_roll': '202214019',
      'guest_phone': '01914347042',
      'linked_cr_roll': '202214003', // Linked CR data present and will be shown with guest data
      'cr_dept_sec': 'CSE | Sec: A',
      'assigned_team': null,
    },
    {
      'id': 'C0002',
      'location': ' Tower 3, Room 401',
      'type': 'Projector',
      'description': 'Projector not turning on.',
      'reported_by': 'Farzana',
      'guest_name': null, // No guest data for this complaint
      'guest_roll': null,
      'guest_phone': null,
      'linked_cr_roll': null, // No linked CR data for this complaint
      'cr_dept_sec': null,
      'assigned_team': null,
    },
    {
      'id': 'C0003',
      'location': ' Tower 3, Room 502',
      'type': 'Computer',
      'description': 'Projector not connecting to PC.',
      'reported_by': 'Samia',
      'guest_name': null,
      'guest_roll': null,
      'guest_phone': null,
      'linked_cr_roll': null, // FIX: Linked CR data set to null as no guest data is present
      'cr_dept_sec': null,    // FIX: CR Dept | Sec set to null
      'assigned_team': null,
    },
    {
      'id': 'C0004',
      'location': ' Tower 3, Room 504',
      'type': 'Electric',
      'description': 'No sound from speakers.',
      'reported_by': 'Rafid',
      'guest_name': null,
      'guest_roll': null,
      'guest_phone': null,
      'linked_cr_roll': null,
      'cr_dept_sec': null,
      'assigned_team': null,
    },
  ];

  final List<String> _availableTeams = [
    'Select a team',
    'Projector Team',
    'Electric Team',
    'Plumbing Team',
    'Computer Team',
    'Housekeeping Team',
    'Furniture Team',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Complaints'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          String? assignedTeam = complaint['assigned_team'];
          String? currentDropdownValue = assignedTeam ?? _availableTeams[0];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.pink[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildComplaintDetailRow(
                    context,
                    icon: Icons.assignment,
                    label: 'Complaint ID',
                    value: complaint['id']!,
                  ),
                  _buildComplaintDetailRow(
                    context,
                    icon: Icons.location_on,
                    label: 'Location',
                    value: complaint['location']!,
                  ),
                  _buildComplaintDetailRow(
                    context,
                    icon: Icons.build,
                    label: 'Type',
                    value: complaint['type']!,
                  ),
                  _buildComplaintDetailRow(
                    context,
                    icon: Icons.edit,
                    label: 'Description',
                    value: complaint['description']!,
                  ),

                  // Guest Complaint Section (only appears if guest_name is not null)
                  if (complaint['guest_name'] != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Guest Complaint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildComplaintDetailRow(
                      context,
                      icon: Icons.person,
                      label: 'Name',
                      value: complaint['guest_name']!,
                    ),
                    _buildComplaintDetailRow(
                      context,
                      icon: Icons.badge,
                      label: 'Roll',
                      value: complaint['guest_roll']!,
                    ),
                    _buildComplaintDetailRow(
                      context,
                      icon: Icons.phone,
                      label: 'Phone',
                      value: complaint['guest_phone']!,
                    ),
                    // Linked CR Roll Section (Now nested inside Guest Complaint,
                    // so it only appears if guest_name is present AND linked_cr_roll is present)
                    if (complaint['linked_cr_roll'] != null) ...[
                      const SizedBox(height: 16),
                      _buildComplaintDetailRow(
                        context,
                        icon: Icons.link,
                        label: 'Linked CR Roll',
                        value: complaint['linked_cr_roll']!,
                      ),
                      if (complaint['cr_dept_sec'] != null)
                        _buildComplaintDetailRow(
                          context,
                          icon: Icons.business,
                          label: 'CR Dept | Sec',
                          value: complaint['cr_dept_sec']!,
                        ),
                    ],
                  ],

                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedTeam == null
                            ? 'Assign to team: '
                            : 'Assigned to: ${assignedTeam}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: assignedTeam == null ? Colors.black : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.pink[100],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.pink.shade200, width: 0.8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: currentDropdownValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.black87, fontSize: 15),
                            onChanged: (String? newValue) {
                              setState(() {
                                complaint['assigned_team'] = newValue == _availableTeams[0] ? null : newValue;
                                print('Assigned ${newValue ?? "nothing"} to ${complaint['description']}');
                              });
                            },
                            items: _availableTeams.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintDetailRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}