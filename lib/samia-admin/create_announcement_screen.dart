import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedTarget;

  final List<String> targets = [
    'ALL', // All CR + All Teams
    'CR', // All CR only
    'TEAM', // All Teams only
    'Electric',
    'Computer',
    'Water',
    'Furniture',
    'Projector',
  ];

  Future<void> _postAnnouncement() async {
    final message = _messageController.text.trim();
    final target = _selectedTarget;

    if (message.isEmpty || target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message and select a target'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'message': message,
        'target': target,
        'timestamp': Timestamp.now(),
        'expired': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted successfully')),
      );

      _messageController.clear();
      setState(() {
        _selectedTarget = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: Colors.pink[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Announcement Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              items: targets.map((target) {
                return DropdownMenuItem<String>(
                  value: target,
                  child: Text(target),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedTarget = value;
                });
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _postAnnouncement,
                icon: const Icon(Icons.check),
                label: const Text('Post Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
