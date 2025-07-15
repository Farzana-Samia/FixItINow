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
    // Notification settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ Android 13+ notification permission
    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (plugin != null) {
      final granted = await plugin.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
    }
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final int generatedOTP = Random().nextInt(900000) + 100000;

    // Show OTP in notification
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
        title: const Text("Guest Login"),
        backgroundColor: Colors.pink[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _sendOTP,
                    icon: const Icon(Icons.message),
                    label: const Text("Send OTP"),
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
