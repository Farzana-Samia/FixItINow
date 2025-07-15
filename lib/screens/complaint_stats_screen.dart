import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pie_chart/pie_chart.dart';

class ComplaintStatsScreen extends StatefulWidget {
  const ComplaintStatsScreen({super.key});

  @override
  State<ComplaintStatsScreen> createState() => _ComplaintStatsScreenState();
}

class _ComplaintStatsScreenState extends State<ComplaintStatsScreen> {
  int submitted = 0;
  int assigned = 0;
  int completed = 0;
  bool loading = true;

  final List<String> teamNames = [
    'Electric',
    'Computer',
    'Furniture',
    'Water',
    'Projector',
  ];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final crComplaints = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .where('userId', isEqualTo: uid)
        .get();

    int submittedCount = 0;
    int assignedCount = 0;
    int completedCount = 0;

    for (var doc in crComplaints.docs) {
      final data = doc.data();
      final assignedTeam = (data['assignedTeam'] ?? "").toString();
      final status = (data['status'] ?? "").toString().toLowerCase();

      if (assignedTeam.isEmpty && status == "pending") {
        submittedCount++;
      } else if (teamNames.contains(assignedTeam) && status == "assigned") {
        assignedCount++;
      } else if (status == "completed") {
        completedCount++;
      }
    }

    setState(() {
      submitted = submittedCount;
      assigned = assignedCount;
      completed = completedCount;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Submitted ($submitted)": submitted.toDouble(),
      "Assigned ($assigned)": assigned.toDouble(),
      "Completed ($completed)": completed.toDouble(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Complaint Stats")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartRadius: MediaQuery.of(context).size.width / 2.2,
                chartType: ChartType.disc,
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: true,
                  decimalPlaces: 1,
                ),
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendPosition: LegendPosition.bottom,
                ),
              ),
            ),
    );
  }
}
