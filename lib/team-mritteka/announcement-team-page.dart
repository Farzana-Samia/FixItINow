import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade700,
        title: const Row(
          children: [
            Icon(Icons.campaign, color: Colors.white),
            SizedBox(width: 8),
            Text('Projector Announcements', style: TextStyle(color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFFAF7F2),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          AnnouncementCard(
            title: 'Supplementary Exam will be held on 15 July from 1400–1700 hrs. '
                'All maintenance teams please be available till 1700 hrs.',
            target: 'TEAM',
            postedOn: '13-07-2025 23:41',
          ),
          SizedBox(height: 10),
          AnnouncementCard(
            title: 'Power outage on 14 July from 0700 to 0900 hrs due to transformer up-gradation',
            target: 'ALL',
            postedOn: '13-07-2025 23:38',
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String target;
  final String postedOn;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.target,
    required this.postedOn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.report_problem, color: Colors.pink),
                SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Target: $target', style: const TextStyle(color: Colors.grey)),
            Text('Posted on: $postedOn', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}