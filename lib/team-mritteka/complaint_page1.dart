import 'package:flutter/material.dart';

class ComplaintDetailsPage extends StatelessWidget {
  const ComplaintDetailsPage({super.key});

  Widget buildDetailCard(String title, String value, {Color? bgColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6005E),
        title: const Text(
          'Complaint Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildDetailCard('Complaint ID', 'C0002'),
            buildDetailCard('Issue', 'Projector'),
            buildDetailCard('Location', 'Room 401 Tower 3'),
            buildDetailCard(
              'Description',
              'Projector and HDMI cable connection are not working',
            ),
            buildDetailCard('Status', 'Ongoing'),
            buildDetailCard(
              'Priority',
              'Yes',
              bgColor: const Color(0xFFFFEB3B), // Yellow background
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6005E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Mark as Completed',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onPressed: () {
                // Handle completion
              },
            )
          ],
        ),
      ),
    );
  }
}
