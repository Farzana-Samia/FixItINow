import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  final String otp; //

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.otp,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  String _error = '';

  Future<void> _verifyOTP() async {
    final enteredCode = _otpController.text.trim();

    if (enteredCode != widget.otp) {
      setState(() => _error = 'Incorrect OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = '';
    });

    try {
      final uid =
          'guest_${widget.phone.replaceAll('+', '').replaceAll(' ', '')}';

      // Store session info in Firestore
      await FirebaseFirestore.instance
          .collection('guest_sessions')
          .doc(uid)
          .set({
            'phone': widget.phone,
            'login_at': FieldValue.serverTimestamp(),
            'expires_at': Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 24)),
            ),
            'uid': uid,
          });

      // Also mark the guest as verified
      await FirebaseFirestore.instance
          .collection('verified_guests')
          .doc(uid)
          .set({
            'mobile': widget.phone,
            'userType': 'guest',
            'verifiedAt': Timestamp.now(),
          });

      if (!mounted) return;

      // ✅ Navigate to Guest Complaint screen using named route
      Navigator.pushReplacementNamed(
        context,
        '/guestComplaint',
        arguments: {'guestUid': uid, 'guestPhone': widget.phone},
      );
    } catch (e) {
      setState(() => _error = 'Failed to verify: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.pink[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "OTP sent to: +88${widget.phone}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _verifyOTP,
                    icon: const Icon(Icons.verified),
                    label: const Text("Verify OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
