import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FileComplaintScreen extends StatefulWidget {
  const FileComplaintScreen({super.key});

  @override
  State<FileComplaintScreen> createState() => _FileComplaintScreenState();
}

class _FileComplaintScreenState extends State<FileComplaintScreen> {
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTeam;
  bool _isPriority = false;
  bool _isSubmitting = false;
  String _errorText = '';

  final List<String> _problemTypes = [
    'Electric',
    'Computer',
    'Projector',
    'Furniture',
    'Water',
  ];

  Future<String> _generateComplaintId() async {
    final counterRef = FirebaseFirestore.instance
        .collection('meta')
        .doc('complaint_counter');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      final data = snapshot.data();
      int currentId = data?['lastId'] ?? 0;
      final newId = currentId + 1;
      transaction.set(counterRef, {'lastId': newId});
      return 'C${newId.toString().padLeft(4, '0')}';
    });
  }

  Future<void> _submitComplaint() async {
    setState(() {
      _isSubmitting = true;
      _errorText = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw '❌ User not logged in';

      if (_locationController.text.trim().isEmpty ||
          _selectedTeam == null ||
          _descriptionController.text.trim().isEmpty) {
        throw '⚠️ Please fill in all fields and select a team';
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw '⚠️ CR profile not found';

      final userData = userDoc.data()!;
      final complaintId = await _generateComplaintId();

      final complaintData = {
        'complaint_id': complaintId,
        'room_location': _locationController.text.trim(),
        'problem_type': _selectedTeam,
        'description': _descriptionController.text.trim(),
        'priority': _isPriority,
        'status': 'Pending',
        'assignedTeam': '',
        'submitted_at': FieldValue.serverTimestamp(),
        'userType': 'cr',
        'userId': user.uid,
        'mist_roll': userData['mist_roll'] ?? '',
        'level': userData['level'],
        'section': userData['section'],
        'department': userData['department'].toString().trim(),
        'designation': 'CR',
      };

      await FirebaseFirestore.instance
          .collection('cr_complaints')
          .add(complaintData);

      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedTeam = null;
        _isPriority = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Complaint submitted successfully')),
        );
      }
    } catch (e) {
      setState(() => _errorText = '$e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0), // Cream white
      appBar: AppBar(
        title: const Text(
          "File Complaint",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF8B5E3C), // Chocolate color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF8B5E3C).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(_locationController, 'Room and Location'),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _descriptionController,
                    'Description',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      "Mark as Priority",
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    activeColor: const Color(0xFF8B5E3C),
                    value: _isPriority,
                    onChanged: (val) =>
                        setState(() => _isPriority = val ?? false),
                  ),
                  if (_errorText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorText,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text("Submit Complaint"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5E3C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 28,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _submitComplaint,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF8B5E3C),
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8B5E3C), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Problem Type',
        labelStyle: const TextStyle(
          color: Color(0xFF8B5E3C),
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: _selectedTeam,
      items: _problemTypes
          .map(
            (team) => DropdownMenuItem(
              value: team,
              child: Text(team, style: const TextStyle(fontFamily: 'Poppins')),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedTeam = val),
    );
  }
}
