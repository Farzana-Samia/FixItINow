import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminSummaryPage extends StatefulWidget {
  const AdminSummaryPage({super.key});

  @override
  State<AdminSummaryPage> createState() => _AdminSummaryPageState();
}

class _AdminSummaryPageState extends State<AdminSummaryPage> {
  // Toggle button selection state: [Daily, Monthly]
  List<bool> _toggleSelection = [true, false];

  // Dropdown selections
  String selectedMonth = 'July';
  String selectedYear = '2025';

  // Sample complaint counts for teams
  final Map<String, int> teamComplaints = {
    'Electric': 5,
    'Computer': 7,
    'Projector': 3,
    'Plumbing': 4,
    'Furniture': 6,
    'Housekeeping': 2,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F2),
      appBar: AppBar(
        backgroundColor: Colors.pink.shade700,
        title: const Text('Admin Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle buttons
            Row(
              children: [
                ToggleButtons(
                  isSelected: _toggleSelection,
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.brown,
                  fillColor: Colors.brown.shade100,
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text("Daily")),
                    Padding(padding: EdgeInsets.all(8), child: Text("Monthly")),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _toggleSelection.length; i++) {
                        _toggleSelection[i] = i == index;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdowns
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  items: const [
                    DropdownMenuItem(value: 'June', child: Text('June')),
                    DropdownMenuItem(value: 'July', child: Text('July')),
                    DropdownMenuItem(value: 'August', child: Text('August')),
                    DropdownMenuItem(value: 'September', child: Text('September')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMonth = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedYear,
                  items: const [
                    DropdownMenuItem(value: '2024', child: Text('2024')),
                    DropdownMenuItem(value: '2025', child: Text('2025')),
                    DropdownMenuItem(value: '2026', child: Text('2026')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart 1 header
            const Row(
              children: [
                Icon(Icons.insert_chart),
                SizedBox(width: 8),
                Text('Submitted vs Assigned',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.red,
                      value: 1,
                      title: '1.0',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 2,
                      title: '2.0',
                      radius: 50,
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),

            const SizedBox(height: 8),

            // Legend aligned right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.circle, color: Colors.red, size: 12),
                SizedBox(width: 4),
                Text('Submitted'),
                SizedBox(width: 24),
                Icon(Icons.circle, color: Colors.blue, size: 12),
                SizedBox(width: 4),
                Text('Assigned'),
              ],
            ),
            const SizedBox(height: 24),

            // Chart 2 header
            const Row(
              children: [
                Icon(Icons.insert_chart_outlined),
                SizedBox(width: 8),
                Text('Assigned Complaint Status',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.orange,
                      value: 1.0,
                      //title: 'Pending',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.purple,
                      value: 1.0,
                      //title: 'Ongoing',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 2.0,
                      //title: 'Completed',
                      radius: 50,
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 8),

            // Legend aligned right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.circle, color: Colors.orange, size: 12),
                SizedBox(width: 4),
                Text('Pending'),
                SizedBox(width: 16),
                Icon(Icons.circle, color: Colors.purple, size: 12),
                SizedBox(width: 4),
                Text('Ongoing'),
                SizedBox(width: 16),
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('Completed'),
              ],
            ),
            const SizedBox(height: 24),

            // Assigned Complaints by Team header
            const Row(
              children: [
                Icon(Icons.build),
                SizedBox(width: 8),
                Text('Assigned Complaints by Team',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            // Teams with progress and completed count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: teamComplaints.entries.map((entry) {
                // Calculate progress as a fraction of 10 complaints for demo
                final progress = (entry.value / 10).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(entry.key),
                      ),
                      Expanded(
                        flex: 5,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.brown.shade400,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Text(
                          entry.value.toString(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
