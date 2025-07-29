import 'package:flutter/material.dart';
import 'cr_profile_page.dart'; // Import the new CRProfilePage

class CRListPage extends StatelessWidget {
  const CRListPage({super.key});

  // Dummy data for Class Representatives
  final List<Map<String, String>> crs = const [
    {
      'name': 'Farzana Samia',
      'email': 'samia.farzana@example.com',
      'mistRoll': '202214019',
      'department': 'CSE',
      'level': '4',
      'section': 'A',
      'mobile': '01812345678',
    },
    {
      'name': 'Abdullah Faisal',
      'email': 'faisal941073@gmail.com',
      // Added dummy data for full profile to pass to CRProfilePage
      'mistRoll': '202214003',
      'department': 'CSE',
      'level': '4',
      'section': 'A',
      'mobile': '01769009410',
    },
    {
      'name': 'Kamal Hossain',
      'email': 'kamal.hossain@example.com',
      'mistRoll': '202214007',
      'department': 'CE',
      'level': '4',
      'section': 'A',
      'mobile': '01712345678',
    },
    {
      'name': 'Nazia Akter',
      'email': 'nazia.akter@example.com',
      'mistRoll': '202214009',
      'department': 'ME',
      'level': '3',
      'section': 'A',
      'mobile': '01912345678',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Representatives'),
        backgroundColor: Colors.pink, // Matching the app's theme
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (Admin Panel)
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( // Use Expanded to make the ListView take remaining space
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding on sides
              itemCount: crs.length,
              itemBuilder: (context, index) {
                final cr = crs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.pink, // Pink circle as in screenshot
                      child: Text(
                        cr['name']![0].toUpperCase(), // First letter of name
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      cr['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        const Text(
                          'Class Representative', // The new description line
                          style: TextStyle(fontSize: 14, color: Colors.black87), // Adjust style as needed
                        ),
                        const SizedBox(height: 2), // Small space between role and email
                        Text(
                          cr['email']!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      // Create a CRProfile object from the dummy data to pass
                      final selectedCR = CRProfile(
                        name: cr['name']!,
                        email: cr['email']!,
                        mistRoll: cr['mistRoll']!,
                        department: cr['department']!,
                        level: cr['level']!,
                        section: cr['section']!,
                        mobile: cr['mobile']!,
                      );

                      // Navigate to the CRProfilePage, passing the selected CR's data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CRProfilePage(crProfile: selectedCR),
                        ),
                      );
                      print('Tapped on ${cr['name']}\'s details');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}