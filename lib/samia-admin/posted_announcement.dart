import 'package:flutter/material.dart';

class PostedAnnouncementsScreen extends StatelessWidget {
  const PostedAnnouncementsScreen({super.key});

  final List<Map<String, String>> announcements = const [
    {
      'content':
      'Supplementary Exam will be held on 15 July from 1400–1700 hrs. All maintenance teams please be available till 1700 hrs.',
      'target': 'TEAM',
      'posted': '2025-07-13 23:41:47',
    },
    {
      'content':
      'Water line maintenance will be held on 17 July in academic tower from 0900 to 1200 hrs.',
      'target': 'CR',
      'posted': '2025-07-13 23:40:43',
    },
    {
      'content':
      'Power outage on 14 July from 0700 to 0900 due to transformer upgradation.',
      'target': 'ALL',
      'posted': '2025-07-13 23:38:14',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Posted Announcements',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(
            context: context,
            content: announcement['content']!,
            target: announcement['target']!,
            postedDate: announcement['posted']!,
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required String content,
    required String target,
    required String postedDate,
    required int index,
  }) {
    // Light pink shades
    final List<Color> pinkShades = [
      const Color(0xFFFFEBEE),
      const Color(0xFFFFEBEE),
      const Color(0xFFFFEBEE),
    ];

    return InkWell(
      onTap: () {
        // Show a SnackBar with a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped announcement:\n"$content"'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: pinkShades[index % pinkShades.length],
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Color(0xFFE91E63), width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Target: $target',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.pink[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Posted: $postedDate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
