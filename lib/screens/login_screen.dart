import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard_screen.dart';
import 'team_dashboard_screen.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'guest_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _error = '';

  void _loginUser() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        setState(() {
          _error = 'Login failed: No UID found';
          _isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .get();

      if (!doc.exists) {
        setState(() {
          _error = 'User data not found in Firestore';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data();
      final userType = data?['userType'];
      final isApproved = data?['isApproved'] ?? true;

      if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (userType == 'team') {
        final teamType = data?['teamType'];
        if (teamType == null || teamType.toString().isEmpty) {
          setState(() {
            _error = 'Team type not found. Contact admin.';
            _isLoading = false;
          });
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDashboardScreen(teamName: teamType),
          ),
        );
      } else if (userType == 'cr') {
        if (!isApproved) {
          setState(() {
            _error = 'Your account is pending approval.';
            _isLoading = false;
          });
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _error = 'Invalid user role.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (_) {
      setState(() {
        _error = 'Invalid email or password. Please try again.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Login failed. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FixItNow',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5E3C),
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.brown[700],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.brown[700],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isLoading ? 'Logging in...' : 'Login',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Register",
                  style: GoogleFonts.lato(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuestLoginScreen()),
                  );
                },
                child: Text(
                  "Continue as CR Rep",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: const Color(0xFF8B5E3C),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
