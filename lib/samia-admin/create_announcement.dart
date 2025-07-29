import 'package:flutter/material.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _contentController = TextEditingController();
  String _selectedTarget = 'ALL';
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')),
        );
        return;
      }

      // Here you would normally send data to your backend or state management

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Announcement created for $_selectedTarget on $_selectedDateTime'),
        ),
      );

      // Clear form
      _contentController.clear();
      setState(() {
        _selectedTarget = 'ALL';
        _selectedDateTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Announcement Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter announcement content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target dropdown
              DropdownButtonFormField<String>(
                value: _selectedTarget,
                decoration: const InputDecoration(
                  labelText: 'Target',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All')),
                  DropdownMenuItem(value: 'CR', child: Text('CR')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                  DropdownMenuItem(value: 'HOUSEKEEPING', child: Text('Housekeeping')),
                  DropdownMenuItem(value: 'ELECTRICAL', child: Text('Electrical')),
                  DropdownMenuItem(value: 'PROJECTOR', child: Text('Projector')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTarget = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date & Time picker
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDateTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDateTime == null
                            ? 'Select Date & Time'
                            : '${_selectedDateTime!.toLocal()}'.split('.')[0],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Announcement'),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
