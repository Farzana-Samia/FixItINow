import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'otp_verification_screen.dart';

class GuestLoginScreen extends StatefulWidget {
  const GuestLoginScreen({super.key});

  @override
  State<GuestLoginScreen> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    final valid = RegExp(r'^(013|014|015|016|017|018|019)\d{8}$');

    if (!valid.hasMatch(phone)) {
      setState(() => _error = 'Enter valid BD number (e.g. 017XXXXXXXX)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final int generatedOTP = Random().nextInt(900000) + 100000;

    await flutterLocalNotificationsPlugin.show(
      0,
      'FixItNow OTP',
      'Your OTP is: $generatedOTP',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'otp_channel',
          'OTP Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OTPVerificationScreen(phone: phone, otp: generatedOTP.toString()),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CR Rep Login"),
        backgroundColor: Colors.pink.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _sendOTP,
                    icon: const Icon(Icons.sms),
                    label: const Text("Send OTP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
