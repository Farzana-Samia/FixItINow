import 'dart:ui';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: const Color(0xFF8B5E3C),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🔶 Background watermark logo
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/mist_logo.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),

          // 🔶 Centered blur container with content
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                        "FixItNow - MIST Classroom Issue Reporting System",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF4B2F1D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "FixItNow is a complaint reporting app designed for students at MIST. "
                        "Class Representatives can report issues related to classroom infrastructure such as lights, fans, projectors, furniture and computers. "
                        "The Admin panel assigns tasks to relevant departments and tracks completion.",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Developed as part of the CSE Software Development Project II at the Military Institute of Science and Technology (MIST).",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
