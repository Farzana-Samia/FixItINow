import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class ComplaintStatsScreen extends StatefulWidget {
  const ComplaintStatsScreen({super.key});

  @override
  State<ComplaintStatsScreen> createState() => _ComplaintStatsScreenState();
}

class _ComplaintStatsScreenState extends State<ComplaintStatsScreen> {
  int submitted = 0;
  int assigned = 0;
  int ongoing = 0;
  int completed = 0;
  bool loading = true;

  String filterType = 'month'; // 'day' or 'month' select any of them
  DateTime selectedDate = DateTime.now();

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
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final crComplaints = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .where('userId', isEqualTo: uid)
        .get();

    int submittedCount = 0;
    int assignedCount = 0;
    int ongoingCount = 0;
    int completedCount = 0;

    for (var doc in crComplaints.docs) {
      final data = doc.data();
      final Timestamp? timestamp = data['submitted_at'];
      final assignedTeam = (data['assignedTeam'] ?? "").toString().trim();
      final status = (data['status'] ?? "").toString().toLowerCase();

      if (timestamp == null) continue;
      final submittedAt = timestamp.toDate();

      // Time filtering
      if (filterType == 'day') {
        if (!(submittedAt.year == selectedDate.year &&
            submittedAt.month == selectedDate.month &&
            submittedAt.day == selectedDate.day))
          continue;
      } else {
        if (!(submittedAt.year == selectedDate.year &&
            submittedAt.month == selectedDate.month))
          continue;
      }

      if (assignedTeam.isEmpty && status == "pending") {
        submittedCount++;
      } else if (teamNames.contains(assignedTeam) && (status == "assigned")) {
        assignedCount++;
      } else if (status == "ongoing") {
        ongoingCount++;
      } else if (status == "completed") {
        completedCount++;
      }
    }

    setState(() {
      submitted = submittedCount;
      assigned = assignedCount;
      ongoing = ongoingCount;
      completed = completedCount;
      loading = false;
    });
  }

  void _selectDate(BuildContext context) async {
    if (filterType == 'day') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() => selectedDate = picked);
        fetchStats();
      }
    } else {
      final DateTime now = DateTime.now();
      final List<String> monthOptions = List.generate(12, (i) {
        return DateFormat('MMMM yyyy').format(DateTime(now.year, i + 1));
      });

      showModalBottomSheet(
        context: context,
        builder: (ctx) => ListView.builder(
          itemCount: monthOptions.length,
          itemBuilder: (ctx, index) {
            final monthDate = DateTime(now.year, index + 1, 1);
            return ListTile(
              title: Text(monthOptions[index]),
              onTap: () {
                setState(() => selectedDate = monthDate);
                Navigator.pop(context);
                fetchStats();
              },
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {
      "Submitted ($submitted)": submitted.toDouble(),
      "Assigned ($assigned)": assigned.toDouble(),
      "Ongoing ($ongoing)": ongoing.toDouble(),
      "Completed ($completed)": completed.toDouble(),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0), // cream white
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C), // chocolate brown
        title: const Text("Complaint Stats"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => filterType = value);
              fetchStats();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text("Daily")),
              const PopupMenuItem(value: 'month', child: Text("Monthly")),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  filterType == 'day'
                      ? "Showing stats for ${DateFormat('dd MMM yyyy').format(selectedDate)}"
                      : "Showing stats for ${DateFormat('MMMM yyyy').format(selectedDate)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5E3C),
                  ),
                ),
                const SizedBox(height: 20),
                PieChart(
                  dataMap: dataMap,
                  animationDuration: const Duration(milliseconds: 800),
                  chartRadius: MediaQuery.of(context).size.width / 2.0,
                  chartType: ChartType.ring,
                  chartLegendSpacing: 40,
                  colorList: const [
                    Color.fromARGB(255, 224, 42, 42),
                    Color.fromARGB(255, 28, 153, 211),
                    Color.fromARGB(255, 219, 15, 127),
                    Color.fromARGB(255, 13, 197, 29),
                  ],
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: true,
                    decimalPlaces: 1,
                  ),
                  legendOptions: const LegendOptions(
                    legendPosition: LegendPosition.bottom,
                    showLegendsInRow: true,
                  ),
                ),
              ],
            ),
    );
  }
}
