import 'package:flutter/material.dart';

class AssignComplaintsPage extends StatefulWidget {
  const AssignComplaintsPage({super.key});

  @override
  State<AssignComplaintsPage> createState() => _AssignComplaintsPageState();
}

class _AssignComplaintsPageState extends State<AssignComplaintsPage> {
  // Dummy data for complaints with an initial null for team assignment
  // This list holds the state of each complaint's assignment
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'issue': 'Projector has no power.',
      'Tower' : '3',
      'location': 'Room 402',
      'reported_by': 'Arif',
      'assigned_team': null, // Null indicates no team assigned yet
    },
    {
      'id': '2',
      'issue': 'Projector not turning on.',
      'Tower' : '3',
      'location': 'Room 401',
      'reported_by': 'Farzana',
      'assigned_team': null,
    },
    {
      'id': '3',
      'issue': 'Projector not connecting to PC.',
      'Tower' : '3',
      'location': 'Room 502',
      'reported_by': 'Samia',
      'assigned_team': null,
    },
    {
      'id': '4',
      'issue': 'No sound from speakers.',
      'Tower' : '3',
      'location': 'Room 504',
      'reported_by': 'Rafid',
      'assigned_team': null,
    },
    {
      'id': '5',
      'issue': 'AC not working',
      'Tower' : '3',
      'location': ' Room 405',
      'reported_by': 'Nadia',
      'assigned_team': null,
    },
  ];

  // Dummy list of available teams for the dropdown
  final List<String> _availableTeams = [
    'Select a team', // This will be the initial placeholder text
    'Projector Team',
    'Electric Team',
    'Plumbing Team',
    'Computer Team ',
    'Housekeeping Team',
    'Furniture Team',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Complaints'),
        backgroundColor: Colors.pink, // Matching the app's theme
        foregroundColor: Colors.white, // Text and icon color on AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
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
            color: Colors.pink[50], // Light pink background for cards
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issue: ${complaint['issue']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Location: ${complaint['location']}'),
                  const SizedBox(height: 4),
                  Text('Reported by: ${complaint['reported_by']}'),
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

                      // FIX: Wrapped DropdownButton in a Container to change its background color
                      Container(
                        width: double.infinity, // Make the container take full width
                        padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding inside the box
                        decoration: BoxDecoration(
                          color: Colors.pink[100], // Slightly darker pink for the box background
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners for the box
                          border: Border.all(color: Colors.pink.shade200, width: 0.8), // Optional subtle border
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: currentDropdownValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.black87, fontSize: 15), // Text color of selected item
                            onChanged: (String? newValue) {
                              setState(() {
                                complaint['assigned_team'] = newValue == _availableTeams[0] ? null : newValue;
                                print('Assigned ${newValue ?? "nothing"} to ${complaint['issue']}');
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
}