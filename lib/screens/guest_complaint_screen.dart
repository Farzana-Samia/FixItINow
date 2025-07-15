import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestComplaintScreen extends StatefulWidget {
  final String guestUid;
  final String guestPhone;

  const GuestComplaintScreen({
    super.key,
    required this.guestUid,
    required this.guestPhone,
  });

  @override
  State<GuestComplaintScreen> createState() => _GuestComplaintScreenState();
}

class _GuestComplaintScreenState extends State<GuestComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestRollController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedLevel;
  String? _selectedSection;
  String? _selectedDept;
  String? _selectedTeam;
  String? _selectedCrId;
  DocumentSnapshot? _selectedCrSnapshot;
  bool _isPriority = false;
  bool _isSubmitting = false;

  final List<String> _levels = ['1', '2', '3', '4'];
  final List<String> _sections = ['A', 'B'];
  final List<String> _departments = ['CSE', 'EEE', 'ME', 'CE'];
  final List<String> _problemTypes = [
    'Electric',
    'Computer',
    'Projector',
    'Furniture',
    'Water',
  ];

  List<DocumentSnapshot> _crList = [];

  Future<void> _fetchCRs() async {
    if (_selectedLevel != null &&
        _selectedSection != null &&
        _selectedDept != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('cr_registrations')
          .where('approved', isEqualTo: true)
          .where('level', isEqualTo: _selectedLevel)
          .where('section', isEqualTo: _selectedSection)
          .where('department', isEqualTo: _selectedDept)
          .get();

      setState(() {
        _crList = snapshot.docs;
        _selectedCrId = null;
        _selectedCrSnapshot = null;
      });
    }
  }

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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
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
        'userType': 'guest',
        'guest_uid': widget.guestUid,
        'guest_name': _guestNameController.text.trim(),
        'guest_roll': _guestRollController.text.trim(),
        'guest_phone': widget.guestPhone,
        'linked_cr_id': _selectedCrSnapshot?.id ?? '',
        'linked_cr_roll': _selectedCrSnapshot?['mist_roll'] ?? '',
        'linked_cr_section': _selectedCrSnapshot?['section'] ?? '',
        'linked_cr_department': _selectedCrSnapshot?['department'] ?? '',
      };

      await FirebaseFirestore.instance
          .collection('guest_complaints')
          .add(complaintData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Complaint submitted successfully")),
        );
      }

      _formKey.currentState!.reset();
      _guestNameController.clear();
      _guestRollController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _isPriority = false;
        _selectedTeam = null;
        _selectedCrId = null;
        _selectedCrSnapshot = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Submission failed: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Complaint"),
        backgroundColor: Colors.pink[700],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_guestNameController, "Your Name"),
                const SizedBox(height: 12),
                _buildTextField(_guestRollController, "MIST Roll"),
                const SizedBox(height: 12),
                _buildDropdown("Department", _departments, _selectedDept, (
                  val,
                ) async {
                  setState(() => _selectedDept = val);
                  await _fetchCRs();
                }),
                const SizedBox(height: 12),
                _buildDropdown("Level", _levels, _selectedLevel, (val) async {
                  setState(() => _selectedLevel = val);
                  await _fetchCRs();
                }),
                const SizedBox(height: 12),
                _buildDropdown("Section", _sections, _selectedSection, (
                  val,
                ) async {
                  setState(() => _selectedSection = val);
                  await _fetchCRs();
                }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCrId,
                  decoration: const InputDecoration(
                    labelText: 'Select CR',
                    border: OutlineInputBorder(),
                  ),
                  items: _crList.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['name'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCrId = val;
                      _selectedCrSnapshot = _crList.firstWhere(
                        (e) => e.id == val,
                      );
                    });
                  },
                ),
                if (_selectedCrSnapshot != null) ...[
                  const SizedBox(height: 8),
                  Text("CR Roll: ${_selectedCrSnapshot!['mist_roll']}"),
                  Text("CR Section: ${_selectedCrSnapshot!['section']}"),
                  Text("CR Dept: ${_selectedCrSnapshot!['department']}"),
                ],
                const SizedBox(height: 12),
                _buildDropdown(
                  "Problem Type",
                  _problemTypes,
                  _selectedTeam,
                  (val) => setState(() => _selectedTeam = val),
                ),
                const SizedBox(height: 12),
                _buildTextField(_locationController, "Room/Location"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Problem Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text("Mark as Priority"),
                  value: _isPriority,
                  onChanged: (val) =>
                      setState(() => _isPriority = val ?? false),
                ),
                const SizedBox(height: 12),
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Submit Complaint"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[700],
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        onPressed: _submitComplaint,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
