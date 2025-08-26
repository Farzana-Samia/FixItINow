import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';

class TeamComplaintStatsScreen extends StatefulWidget {
  final String teamName;

  const TeamComplaintStatsScreen({super.key, required this.teamName});

  @override
  State<TeamComplaintStatsScreen> createState() =>
      _TeamComplaintStatsScreenState();
}

class _TeamComplaintStatsScreenState extends State<TeamComplaintStatsScreen> {
  int assigned = 0;
  int ongoing = 0;
  int teamCompleted = 0;
  int finalCompleted = 0;
  bool isLoading = true;

  bool isMonthly = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchComplaintStats();
  }

  Future<void> fetchComplaintStats() async {
    setState(() => isLoading = true);

    int assignedCount = 0;
    int ongoingCount = 0;
    int teamCompletedCount = 0;
    int finalCompletedCount = 0;

    Timestamp start;
    Timestamp end;

    if (isMonthly) {
      start = Timestamp.fromDate(
        DateTime(selectedDate.year, selectedDate.month, 1),
      );
      end = Timestamp.fromDate(
        DateTime(selectedDate.year, selectedDate.month + 1, 1),
      );
    } else {
      start = Timestamp.fromDate(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      );
      end = Timestamp.fromDate(
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1),
      );
    }

    try {
      final crSnapshot = await FirebaseFirestore.instance
          .collection('cr_complaints')
          .where('assignedTeam', isEqualTo: widget.teamName)
          .where('submitted_at', isGreaterThanOrEqualTo: start)
          .where('submitted_at', isLessThan: end)
          .get();

      final guestSnapshot = await FirebaseFirestore.instance
          .collection('guest_complaints')
          .where('assignedTeam', isEqualTo: widget.teamName)
          .where('submitted_at', isGreaterThanOrEqualTo: start)
          .where('submitted_at', isLessThan: end)
          .get();

      final allDocs = [...crSnapshot.docs, ...guestSnapshot.docs];

      for (var doc in allDocs) {
        final status = doc['status'] ?? '';
        switch (status) {
          case 'Assigned':
            assignedCount++;
            break;
          case 'Ongoing':
            ongoingCount++;
            break;
          case 'Team_Completed':
            teamCompletedCount++;
            break;
          case 'Final_Completed':
            finalCompletedCount++;
            break;
        }
      }

      setState(() {
        assigned = assignedCount;
        ongoing = ongoingCount;
        teamCompleted = teamCompletedCount;
        finalCompleted = finalCompletedCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  /// Build the map for pie_chart:
  /// - Only include non-zero statuses.
  /// - If all zero, return a single "No data" slice so the chart is a solid ring.
  Map<String, double> _buildDataMap() {
    final map = <String, double>{};
    if (assigned > 0) map['Assigned'] = assigned.toDouble();
    if (ongoing > 0) map['Ongoing'] = ongoing.toDouble();
    if (teamCompleted > 0) map['Team Completed'] = teamCompleted.toDouble();
    if (finalCompleted > 0) map['Final Completed'] = finalCompleted.toDouble();

    if (map.isEmpty) {
      // Single ash/black ring when nothing exists
      return {'No data': 1};
    }
    return map;
  }

  /// Colors aligned to the data order above.
  /// When showing "No data", return a single ash/black color.
  List<Color> _buildColorList(Map<String, double> dataMap) {
    if (dataMap.length == 1 && dataMap.containsKey('No data')) {
      return [const Color.fromARGB(255, 175, 175, 175)]; // ash color ring
    }
    final colors = <Color>[];
    if (dataMap.containsKey('Assigned')) colors.add(Colors.blue);
    if (dataMap.containsKey('Ongoing')) colors.add(Colors.orange);
    if (dataMap.containsKey('Team Completed')) colors.add(Colors.teal);
    if (dataMap.containsKey('Final Completed')) colors.add(Colors.green);
    return colors;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchComplaintStats();
    }
  }

  Widget _buildLegendTile(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = isMonthly
        ? "Showing stats for ${DateFormat.yMMMM().format(selectedDate)}"
        : "Showing stats for ${DateFormat.yMMMd().format(selectedDate)}";

    final total = assigned + ongoing + teamCompleted + finalCompleted;
    final hasData = total > 0;

    final dataMap = _buildDataMap();
    final colors = _buildColorList(dataMap);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        title: Text("${widget.teamName} Team Stats"),
        backgroundColor: const Color(0xFF8B5E3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: isMonthly ? 'Switch to Daily' : 'Switch to Monthly',
            onPressed: () {
              setState(() => isMonthly = !isMonthly);
              fetchComplaintStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // 👇 pie_chart fix: single ash ring when empty, otherwise only non-zero slices
                PieChart(
                  dataMap: dataMap,
                  animationDuration: const Duration(milliseconds: 800),
                  chartRadius: MediaQuery.of(context).size.width / 2.2,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 25,
                  colorList: colors,
                  chartValuesOptions: ChartValuesOptions(
                    showChartValues: hasData, // hide values when empty
                    showChartValuesInPercentage: hasData,
                    chartValueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    showChartValueBackground: false,
                  ),
                  legendOptions: const LegendOptions(
                    legendPosition: LegendPosition.bottom,
                    showLegends: false,
                  ),
                ),

                const SizedBox(height: 20),
                _buildLegendTile(Colors.blue, 'Assigned ($assigned)'),
                _buildLegendTile(Colors.orange, 'Ongoing ($ongoing)'),
                _buildLegendTile(
                  Colors.teal,
                  'Team Completed ($teamCompleted)',
                ),
                _buildLegendTile(
                  Colors.green,
                  'Final Completed ($finalCompleted)',
                ),

                if (!hasData)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'No complaints found for this time period.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
              ],
            ),
    );
  }
}
