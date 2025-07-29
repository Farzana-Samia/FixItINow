import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: const Color(0xFF8B5E3C),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.18, // Slightly increased for visibility
              child: Image.asset(
                'assets/images/mist_logo.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F0).withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B5E3C)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "FixItNow - Contact Information",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4B2F1D),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "📧 Email: support@fixitnow.com",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "📞 Phone: +880 1769-001111",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "🏫 Address: Department of CSE, Military Institute of Science and Technology (MIST), Mirpur Cantonment, Dhaka, Bangladesh",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "We value your feedback and are here to support you with any classroom issue reporting.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
