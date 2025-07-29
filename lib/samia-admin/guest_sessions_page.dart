import 'package:flutter/material.dart';

class GuestSessionsPage extends StatelessWidget {
  const GuestSessionsPage({super.key});

  static const List<Map<String, String>> guestSessions = [
    {
      'name': 'Unknown',
      'phone': '01769001111',
      'uid': 'guest_01769001111',
      'loginAt': '12 Jul 2025 03:16 AM',
      'expiresAt': '13 Jul 2025 03:16 AM',
      'logoutStatus': 'Force Logged Out',
      'complaint': 'No',
      'complaintId': 'N/A',
    },
    {
      'name': 'Unknown',
      'phone': '01769009410',
      'uid': 'guest_01769009410',
      'loginAt': '16 Jul 2025 01:17 AM',
      'expiresAt': '17 Jul 2025 01:16 AM',
      'logoutStatus': 'Force Logged Out',
      'complaint': 'No',
      'complaintId': 'N/A',
    },
    {
      'name': 'Farzana Mozammel Samia',
      'phone': '01914347042',
      'uid': 'guest_01914347042',
      'loginAt': '09 Jul 2025 02:52 AM',
      'expiresAt': '10 Jul 2025 02:51 AM',
      'logoutStatus': 'Force Logged Out',
      'complaint': 'Yes',
      'complaintId': 'C0001',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Sessions'),
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
        itemCount: guestSessions.length,
        itemBuilder: (context, index) {
          final session = guestSessions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.pink[50],
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
              title: Text(
                session['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(session['phone']!),
              trailing: const Icon(Icons.keyboard_arrow_down),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _buildSessionDetail(context, icon: Icons.fingerprint, label: 'UID', value: session['uid']!),
                _buildSessionDetail(context, icon: Icons.login, label: 'Login At', value: session['loginAt']!),
                _buildSessionDetail(context, icon: Icons.calendar_today, label: 'Expires At', value: session['expiresAt']!),
                _buildSessionDetail(context, icon: Icons.logout, label: 'Logout Status', value: session['logoutStatus']!, valueColor: Colors.red),
                _buildSessionDetail(context, icon: Icons.assignment, label: 'Complaint', value: session['complaint']!, valueColor: session['complaint'] == 'Yes' ? Colors.green : null),
                _buildSessionDetail(context, icon: Icons.info, label: 'Complaint ID', value: session['complaintId']!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionDetail(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
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
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: valueColor ?? Colors.black,
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
