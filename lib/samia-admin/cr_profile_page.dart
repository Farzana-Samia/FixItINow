import 'package:flutter/material.dart';

// This class represents the structure of a CR's profile data.
// In a real app, this might come from a database or API.
class CRProfile {
  final String name;
  final String role;
  final String mistRoll;
  final String department;
  final String level;
  final String section;
  final String mobile;
  final String email;

  CRProfile({
    required this.name,
    this.role = 'Class Representative', // Default role for CRs
    required this.mistRoll,
    required this.department,
    required this.level,
    required this.section,
    required this.mobile,
    required this.email,
  });
}

class CRProfilePage extends StatelessWidget {
  final CRProfile crProfile;

  const CRProfilePage({super.key, required this.crProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'), // Title as seen in screenshot
        backgroundColor: Colors.pink, // Matching app theme
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (CR List)
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top gradient section with profile picture and name/role
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade400, Colors.teal.shade300], // Gradient colors from screenshot
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.pink.shade700, // Darker pink for avatar
                    child: Text(
                      crProfile.name[0].toUpperCase(), // First letter of name
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    crProfile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    crProfile.role, // "Class Representative"
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space between top section and detail cards

            // List of profile details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildProfileDetailCard(
                    icon: Icons.person,
                    label: 'MIST Roll',
                    value: crProfile.mistRoll,
                  ),
                  _buildProfileDetailCard(
                    icon: Icons.business, // Building icon for department
                    label: 'Department',
                    value: crProfile.department,
                  ),
                  _buildProfileDetailCard(
                    icon: Icons.star, // Star icon for level
                    label: 'Level',
                    value: crProfile.level,
                  ),
                  _buildProfileDetailCard(
                    icon: Icons.group, // Group icon for section
                    label: 'Section',
                    value: crProfile.section,
                  ),
                  _buildProfileDetailCard(
                    icon: Icons.phone,
                    label: 'Mobile',
                    value: crProfile.mobile,
                  ),
                  _buildProfileDetailCard(
                    icon: Icons.email,
                    label: 'Email',
                    value: crProfile.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Helper method to build each profile detail card
  Widget _buildProfileDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink, size: 28), // Icon matching theme
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}