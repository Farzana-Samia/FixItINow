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
        });
        return;
      }

      final data = doc.data()!;
      final userType = data['userType'] ?? '';
      final approvedRaw = data['approved'];
      final approved = approvedRaw == true || approvedRaw == 'true';

      if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (userType == 'team') {
        final teamType = data['teamType'];
        if (teamType == null || teamType.toString().isEmpty) {
          setState(() => _error = 'Team type not found. Contact admin.');
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TeamDashboardScreen(teamName: teamType),
          ),
        );
      } else if (userType == 'cr') {
        if (approved) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          setState(() => _error = 'Your CR account is pending admin approval.');
        }
      } else {
        setState(() => _error = 'Invalid role. Contact admin.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Authentication failed');
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F4F0);
    const Color accent = Color(0xFFA67C52);
    const double fieldFontSize = 16;
    const double labelFontSize = 18;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'FixItNow',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    fontSize: labelFontSize,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(emailController, "Enter your email", accent),

              const SizedBox(height: 20),

              // Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: GoogleFonts.poppins(
                    fontSize: labelFontSize,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(
                passwordController,
                "Enter your password",
                accent,
                obscure: true,
              ),

              const SizedBox(height: 20),

              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: GoogleFonts.poppins(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              // Login button
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // More rounded
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 28),

              // Register + Guest
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text(
                  "Don't have an account? Register",
                  style: GoogleFonts.poppins(
                    color: Colors.brown.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuestLoginScreen()),
                  );
                },
                child: Text(
                  "Continue as Guest",
                  style: GoogleFonts.poppins(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    Color accentColor, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 1.4),
        ),
      ),
    );
  }
}
