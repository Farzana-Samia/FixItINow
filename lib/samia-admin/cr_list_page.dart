import 'package:flutter/material.dart';
import 'cr_profile_page.dart'; // Import your profile page

class CRListPage extends StatelessWidget {
  const CRListPage({super.key});

  // Approved CRs
  final List<Map<String, String>> approvedCRs = const [
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

  // Pending CRs
  final List<Map<String, String>> pendingCRs = const [
    {
      'name': 'Samia',
      'email': 'farzanasamia4@gmail.com',
      'mistRoll': '202214019',
      'department': 'CSE',
      'level': '4',
      'section': 'B',
      'mobile': '01914347042',
    },
    {
      'name': 'Hasan Mahmud',
      'email': 'hasanmahmud@example.com',
      'mistRoll': '202214045',
      'department': 'EECE',
      'level': '2',
      'section': 'A',
      'mobile': '01876543210',
    },
  ];

  // Dialog for pending CR
  void _showCRDialog(BuildContext context, Map<String, String> cr) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('CR Registration Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${cr['name']}'),
            Text('MIST Roll: ${cr['mistRoll']}'),
            Text('Email: ${cr['email']}'),
            Text('Mobile: ${cr['mobile']}'),
            Text('Level: ${cr['level']}'),
            Text('Section: ${cr['section']}'),
            Text('Department: ${cr['department']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CR Approved')),
              );
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CR Declined')),
              );
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Representatives'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pending CR Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingCRs.length,
              itemBuilder: (context, index) {
                final cr = pendingCRs[index];
                return Card(
                  color: Colors.pink[50],
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(cr['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pending Approval'),
                    trailing: const Icon(Icons.info_outline, color: Colors.pink),
                    onTap: () => _showCRDialog(context, cr),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Approved CRs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: approvedCRs.length,
              itemBuilder: (context, index) {
                final cr = approvedCRs[index];
                return Card(
                  color: Colors.pink[50],
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Text(
                        cr['name']![0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(cr['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(cr['email']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      final selectedCR = CRProfile(
                        name: cr['name']!,
                        email: cr['email']!,
                        mistRoll: cr['mistRoll']!,
                        department: cr['department']!,
                        level: cr['level']!,
                        section: cr['section']!,
                        mobile: cr['mobile']!,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CRProfilePage(crProfile: selectedCR),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
