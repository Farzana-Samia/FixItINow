import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = '';
  String email = '';
  String mistRoll = '';
  String department = '';
  String level = '';
  String section = '';
  String mobile = '';
  String userType = '';
  bool _loading = true;

  // Local theme toggle
  bool _isDarkTheme = false;

  final Color creamWhite = const Color(0xFFF8F4F0);
  final Color chocolateBrown = const Color(0xFF8B5E3C);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          mistRoll = data['mist_roll'] ?? '';
          department = data['department'] ?? '';
          level = data['level'] ?? '';
          section = data['section'] ?? '';
          mobile = data['mobile'] ?? '';
          userType = data['userType'] ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkTheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : creamWhite,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: chocolateBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Toggle Theme",
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkTheme = !_isDarkTheme;
              });
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: chocolateBrown,
                  backgroundImage: const AssetImage('assets/user.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: 'Sans',
                  ),
                ),
                Text(
                  userType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: chocolateBrown.withOpacity(0.85),
                    fontFamily: 'Sans',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCardTile(
                        Icons.badge,
                        "MIST Roll",
                        mistRoll,
                        isDark,
                      ),
                      _buildCardTile(
                        Icons.apartment,
                        "Department",
                        department,
                        isDark,
                      ),
                      _buildCardTile(Icons.grade, "Level", level, isDark),
                      _buildCardTile(Icons.group, "Section", section, isDark),
                      _buildCardTile(Icons.phone, "Mobile", mobile, isDark),
                      _buildCardTile(Icons.email, "Email", email, isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCardTile(
    IconData icon,
    String title,
    String value,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shadowColor: Colors.brown.shade100,
      color: isDark ? const Color(0xFF2B2B2B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: chocolateBrown),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Sans',
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'N/A',
          style: TextStyle(
            fontFamily: 'Sans',
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
