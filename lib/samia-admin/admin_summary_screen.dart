import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class AdminSummaryScreen extends StatefulWidget {
  const AdminSummaryScreen({super.key});

  @override
  State<AdminSummaryScreen> createState() => _AdminSummaryScreenState();
}

class _AdminSummaryScreenState extends State<AdminSummaryScreen> {
  bool isMonthly = false;
  DateTime selectedDate = DateTime.now();
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int selectedYear = DateTime.now().year;

  Map<String, double> submissionCounts = {'Submitted': 0, 'Assigned': 0};
  Map<String, double> assignedStatusCounts = {
    'Pending': 0,
    'Ongoing': 0,
    'Completed': 0,
  };
  Map<String, double> teamCounts = {
    'Electric': 0,
    'Computer': 0,
    'Projector': 0,
    'Furniture': 0,
    'Water': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchComplaintData();
  }

  Future<void> fetchComplaintData() async {
    final crSnapshot = await FirebaseFirestore.instance
        .collection('cr_complaints')
        .get();
    final guestSnapshot = await FirebaseFirestore.instance
        .collection('guest_complaints')
        .get();

    final allDocs = [...crSnapshot.docs, ...guestSnapshot.docs];
    final teams = ['Electric', 'Computer', 'Furniture', 'Water', 'Projector'];

    final startDate = isMonthly
        ? DateTime(selectedYear, months.indexOf(selectedMonth) + 1, 1)
        : DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final endDate = isMonthly
        ? DateTime(selectedYear, months.indexOf(selectedMonth) + 2, 1)
        : startDate.add(const Duration(days: 1));

    double submitted = 0, assigned = 0;
    Map<String, double> statusMap = {
      'Pending': 0,
      'Ongoing': 0,
      'Completed': 0,
    };
    Map<String, double> teamMap = {
      'Electric': 0,
      'Computer': 0,
      'Projector': 0,
      'Furniture': 0,
      'Water': 0,
    };

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>;

      final Timestamp ts = data['submitted_at'];
      final DateTime submittedAt = ts.toDate();
      if (submittedAt.isBefore(startDate) || submittedAt.isAfter(endDate)) {
        continue;
      }

      final status = data['status'] ?? '';
      final assignedTeam = data['assignedTeam'] ?? '';
      final problemType = data['problem_type'] ?? '';

      if (assignedTeam == "" && status == "Pending") {
        submitted++;
      } else if (teams.contains(assignedTeam) && status == "Assigned") {
        assigned++;
        statusMap['Pending'] = statusMap['Pending']! + 1;
        if (teamMap.containsKey(assignedTeam)) {
          teamMap[assignedTeam] = teamMap[assignedTeam]! + 1;
        }
      } else if (teams.contains(assignedTeam) && status == "Ongoing") {
        assigned++;
        statusMap['Ongoing'] = statusMap['Ongoing']! + 1;
        if (teamMap.containsKey(assignedTeam)) {
          teamMap[assignedTeam] = teamMap[assignedTeam]! + 1;
        }
      } else if (status == "Completed") {
        assigned++;
        statusMap['Completed'] = statusMap['Completed']! + 1;
        if (teamMap.containsKey(assignedTeam)) {
          teamMap[assignedTeam] = teamMap[assignedTeam]! + 1;
        }
      }
    }

    setState(() {
      submissionCounts = {'Submitted': submitted, 'Assigned': assigned};
      assignedStatusCounts = statusMap;
      teamCounts = teamMap;
    });
  }

  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<int> years = [2024, 2025, 2026];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📈 Admin Summary"),
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ToggleButtons(
            isSelected: [!isMonthly, isMonthly],
            onPressed: (index) {
              setState(() {
                isMonthly = index == 1;
              });
              fetchComplaintData();
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Daily"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Monthly"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isMonthly)
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                  fetchComplaintData();
                }
              },
              child: Text(
                "Pick Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
              ),
            )
          else
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months
                      .map(
                        (month) =>
                            DropdownMenuItem(value: month, child: Text(month)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                    fetchComplaintData();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: selectedYear,
                  items: years
                      .map(
                        (year) =>
                            DropdownMenuItem(value: year, child: Text('$year')),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                    fetchComplaintData();
                  },
                ),
              ],
            ),
          const SizedBox(height: 24),
          const Text(
            "🧾 Submitted vs Assigned",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          PieChart(
            dataMap: submissionCounts,
            chartType: ChartType.ring,
            chartRadius: MediaQuery.of(context).size.width / 2.2,
            colorList: [
              Colors.redAccent, // Submitted
              Colors.blueAccent, // Assigned
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            "📊 Assigned Complaint Status",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          PieChart(
            dataMap: assignedStatusCounts,
            chartType: ChartType.ring,
            chartRadius: MediaQuery.of(context).size.width / 2.2,
            colorList: [
              const Color.fromARGB(255, 247, 153, 14), // Pending
              const Color.fromARGB(255, 139, 120, 223), // Ongoing
              const Color.fromARGB(255, 22, 224, 171), // Completed
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            "🛠 Assigned Complaints by Team",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...teamCounts.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(entry.key)),
                  Expanded(
                    flex: 6,
                    child: LinearProgressIndicator(
                      value: submissionCounts['Assigned']! > 0
                          ? entry.value / submissionCounts['Assigned']!
                          : 0,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                      minHeight: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(entry.value.toInt().toString()),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
