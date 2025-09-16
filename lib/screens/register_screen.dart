import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mistRollController = TextEditingController();
  final levelController = TextEditingController();
  final sectionController = TextEditingController();
  final deptController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.signOut();
  }

  Future<bool> _checkDuplicate(String mistRoll, String email) async {
    final query = await FirebaseFirestore.instance
        .collection('cr_registrations')
        .where('mist_roll', isEqualTo: mistRoll)
        .get();

    final queryEmail = await FirebaseFirestore.instance
        .collection('cr_registrations')
        .where('email', isEqualTo: email)
        .get();

    return query.docs.isNotEmpty || queryEmail.docs.isNotEmpty;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final mistRoll = mistRollController.text.trim();
      final email = emailController.text.trim();

      final alreadyExists = await _checkDuplicate(mistRoll, email);
      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ Email or MIST Roll already registered!"),
          ),
        );
        setState(() => _loading = false);
        return;
      }

      // ✅ Create Firebase Auth account
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text.trim(),
          );

      String uid = userCred.user!.uid;

      // ✅ Save CR info to Firestore
      await FirebaseFirestore.instance
          .collection('cr_registrations')
          .doc(uid)
          .set({
            'name': nameController.text.trim(),
            'mist_roll': mistRoll,
            'level': levelController.text.trim(),
            'section': sectionController.text.trim(),
            'department': deptController.text.trim(),
            'email': email,
            'mobile': mobileController.text.trim(),
            'uid': uid,
            'approved': false,
            'timestamp': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registration submitted! Await admin approval."),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "❌ Registration failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ An unexpected error occurred.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CR Registration"),
        backgroundColor: const Color(0xFF8B5E3C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildField("Name", nameController),
              buildField("MIST Roll No", mistRollController),
              buildField("Level", levelController),
              buildField("Section", sectionController),
              buildField("Department", deptController),
              buildField("Email", emailController),
              buildField("Mobile", mobileController),
              buildField("Password", passwordController, obscure: true),

              // --- NEW: single-line consent message (just text) ---
              const SizedBox(height: 12),
              const Text(
                "By tapping Register, I consent to use of my info and it remains private unless required by law.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),

              // ----------------------------------------------------
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                ),
                onPressed: _loading ? null : _submitForm,
                child: _loading
                    ? const CircularProgressIndicator(color: Color(0xFFF8F4F0))
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }
}
