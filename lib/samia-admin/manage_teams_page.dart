import 'package:flutter/material.dart';

class ManageTeamsPage extends StatelessWidget {
  const ManageTeamsPage({super.key});

  // Updated dummy data for teams to include a complaint count
  final List<Map<String, dynamic>> teams = const [
    {
      'name': 'Electrical Team',
      'total_complaints': 15,
    },
    {
      'name': 'Furniture Team',
      'total_complaints': 7,
    },
    {
      'name': 'Projector Team',
      'total_complaints': 3,
    },
    {
      'name': 'Computer Team',
      'total_complaints': 8,
    },
    {
      'name': 'Plumbing Team',
      'total_complaints': 12,
    },
    {
      'name': 'Housekeeping Team',
      'total_complaints': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Teams'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 16.0, // Horizontal space between cards
            mainAxisSpacing: 16.0, // Vertical space between cards
            childAspectRatio: 0.9, // ✅ Taller cards to avoid overflow
          ),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return Card(
              color: Colors.pink[50], // Light pink background
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: InkWell(
                onTap: () {
                  // TODO: Implement navigation to a specific team's details or complaints
                  print('Tapped on ${team['name']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing details for "${team['name']}"')),
                  );
                },
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        team['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink, // Darker pink for text
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total complaints: ${team['total_complaints']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
